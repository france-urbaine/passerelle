CREATE OR REPLACE FUNCTION trigger_epcis_changes()
RETURNS trigger
AS $function$
  BEGIN
    -- Reset self counters
    -- * on creation
    -- * when siren changed
    -- * when code_departement changed (could be NULL)

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'UPDATE' AND NEW."siren" <> OLD."siren")
    OR (TG_OP = 'UPDATE' AND NEW."code_departement" <> OLD."code_departement")
    OR (TG_OP = 'UPDATE' AND (NEW."code_departement" IS NULL) <> (OLD."code_departement"  IS NULL))
    THEN

      UPDATE  "epcis"
      SET     "communes_count"       = get_epcis_communes_count("epcis".*),
              "collectivities_count" = get_epcis_collectivities_count("epcis".*)
      WHERE   "epcis"."id" = NEW."id";

    END IF;

    -- Reset all epcis_count & collectivities_count
    -- * on creation
    -- * on deletion
    -- * when siren changed
    -- * when code_departement changed (could be NULL)

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."siren" <> OLD."siren")
    OR (TG_OP = 'UPDATE' AND NEW."code_departement" <> OLD."code_departement")
    OR (TG_OP = 'UPDATE' AND (NEW."code_departement" IS NULL) <> (OLD."code_departement"  IS NULL))
    THEN

      UPDATE  "communes"
      SET     "collectivities_count" = get_communes_collectivities_count("communes".*)
      WHERE   "communes"."siren_epci" IN (NEW."siren", OLD."siren");

      UPDATE  "departements"
      SET     "epcis_count"          = get_departements_epcis_count("departements".*),
              "collectivities_count" = get_departements_collectivities_count("departements".*)
      WHERE   "departements"."code_departement" IN (NEW."code_departement", OLD."code_departement")
        OR    "departements"."code_departement" IN (
                SELECT "communes"."code_departement"
                FROM   "communes"
                WHERE  "communes"."siren_epci" IN (NEW."siren", OLD."siren")
              );

      UPDATE  "regions"
      SET     "epcis_count"          = get_regions_epcis_count("regions".*),
              "collectivities_count" = get_regions_collectivities_count("regions".*)
      WHERE   "regions"."code_region" IN (
                SELECT  "departements"."code_region"
                FROM    "departements"
                WHERE   "departements"."code_departement" IN (NEW."code_departement", OLD."code_departement")
                  OR    "departements"."code_departement" IN (
                          SELECT "communes"."code_departement"
                          FROM   "communes"
                          WHERE  "communes"."siren_epci" IN (NEW."siren", OLD."siren")
                        )
              );

      UPDATE  "ddfips"
      SET     "collectivities_count" = get_ddfips_collectivities_count("ddfips".*)
      WHERE   "ddfips"."code_departement" IN (NEW."code_departement", OLD."code_departement")
        OR    "ddfips"."code_departement" IN (
                SELECT "communes"."code_departement"
                FROM   "communes"
                WHERE  "communes"."siren_epci" IN (NEW."siren", OLD."siren")
              );

    END IF;

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$function$ LANGUAGE plpgsql;
