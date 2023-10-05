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
      SET    "collectivities_count" = get_communes_collectivities_count("communes".*)
      WHERE  "communes"."id" = NEW."id";

    END IF;

    -- Reset communes#offices_count
    -- * on creation
    -- * when code_insee changed (it shouldn't)

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'UPDATE' AND NEW."code_insee" <> OLD."code_insee")
    THEN

      UPDATE  "communes"
      SET     "offices_count" = get_communes_offices_count("communes".*)
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
      SET     "communes_count" = get_offices_communes_count("offices".*)
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
      SET     "communes_count"       = get_epcis_communes_count("epcis".*),
              "collectivities_count" = get_epcis_collectivities_count("epcis".*)
      WHERE   "epcis"."siren" IN (NEW."siren_epci", OLD."siren_epci");

      UPDATE  "departements"
      SET     "communes_count"       = get_departements_communes_count("departements".*),
              "collectivities_count" = get_departements_collectivities_count("departements".*)
      WHERE   "departements"."code_departement" IN (NEW."code_departement", OLD."code_departement");

      UPDATE  "regions"
      SET     "communes_count"       = get_regions_communes_count("regions".*),
              "collectivities_count" = get_regions_collectivities_count("regions".*)
      WHERE   "regions"."code_region" IN (
                SELECT "departements"."code_region"
                FROM   "departements"
                WHERE  "departements"."code_departement" IN (NEW."code_departement", OLD."code_departement")
              );

      UPDATE  "ddfips"
      SET     "collectivities_count" = get_ddfips_collectivities_count("ddfips".*)
      WHERE   "ddfips"."code_departement" IN (NEW."code_departement", OLD."code_departement");

    END IF;

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$function$ LANGUAGE plpgsql;

