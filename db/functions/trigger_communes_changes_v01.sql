CREATE OR REPLACE FUNCTION trigger_communes_changes()
RETURNS trigger
AS $function$
  BEGIN
    -- Reset communes#collectivities_count
    -- * on creation
    -- * when code_departement changed
    -- * when siren_epci changed (could be NULL)

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'UPDATE' AND NEW."code_departement" <> OLD."code_departement")
    OR (TG_OP = 'UPDATE' AND NEW."siren_epci" <> OLD."siren_epci")
    OR (TG_OP = 'UPDATE' AND (NEW."siren_epci" IS NULL) <> (OLD."siren_epci" IS NULL))
    THEN

      UPDATE "communes"
      SET    "collectivities_count" = get_collectivities_count_in_communes("communes".*)
      WHERE  "communes"."id" = NEW."id";

    END IF;

    -- Reset communes#offices_count
    -- * on creation
    -- * when code_insee changed (it shouldn't)

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'UPDATE' AND NEW."code_insee" <> OLD."code_insee")
    THEN

      UPDATE  "communes"
      SET     "offices_count" = get_offices_count_in_communes("communes".*)
      WHERE   "communes"."id" = NEW."id";

    END IF;

    -- Reset offices#communes_count
    -- * on creation
    -- * on deletion
    -- * when code_insee changed (it shouldn't)

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."code_insee" <> OLD."code_insee")
    THEN

      UPDATE  "offices"
      SET     "communes_count" = get_communes_count_in_offices("offices".*)
      WHERE   "offices"."id" IN (
        SELECT "office_communes"."office_id"
        FROM   "office_communes"
        WHERE  "office_communes"."code_insee" IN (NEW."code_insee", OLD."code_insee")
      );

    END IF;

    -- Reset all communes_count & collectivities_count
    -- * on creation
    -- * on deletion
    -- * when code_departement changed
    -- * when siren_epci changed (could be NULL)

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."code_departement" <> OLD."code_departement")
    OR (TG_OP = 'UPDATE' AND NEW."siren_epci" <> OLD."siren_epci")
    OR (TG_OP = 'UPDATE' AND (NEW."siren_epci" IS NULL) <> (OLD."siren_epci" IS NULL))
    THEN

      UPDATE  "epcis"
      SET     "communes_count"       = get_communes_count_in_epcis("epcis".*),
              "collectivities_count" = get_collectivities_count_in_epcis("epcis".*)
      WHERE   "epcis"."siren" IN (NEW."siren_epci", OLD."siren_epci");

      UPDATE  "departements"
      SET     "communes_count"       = get_communes_count_in_departements("departements".*),
              "collectivities_count" = get_collectivities_count_in_departements("departements".*)
      WHERE   "departements"."code_departement" IN (NEW."code_departement", OLD."code_departement");

      UPDATE  "regions"
      SET     "communes_count"       = get_communes_count_in_regions("regions".*),
              "collectivities_count" = get_collectivities_count_in_regions("regions".*)
      WHERE   "regions"."code_region" IN (
                SELECT "departements"."code_region"
                FROM   "departements"
                WHERE  "departements"."code_departement" IN (NEW."code_departement", OLD."code_departement")
              );

      UPDATE  "ddfips"
      SET     "collectivities_count" = get_collectivities_count_in_ddfips("ddfips".*)
      WHERE   "ddfips"."code_departement" IN (NEW."code_departement", OLD."code_departement");

    END IF;

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$function$ LANGUAGE plpgsql;

