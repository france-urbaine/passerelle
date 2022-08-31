CREATE OR REPLACE FUNCTION trigger_departements_changes()
RETURNS trigger
AS $function$
  BEGIN
    -- Reset self counters
    -- * on creation
    -- * when code_region changed
    -- * when code_departement changed
    -- * when code_departement changed

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'UPDATE' AND NEW."code_region" <> OLD."code_region")
    OR (TG_OP = 'UPDATE' AND NEW."code_departement" <> OLD."code_departement")
    THEN

      UPDATE  "departements"
      SET     "communes_count"       = get_departements_communes_count("departements".*),
              "epcis_count"          = get_departements_epcis_count("departements".*),
              "collectivities_count" = get_departements_collectivities_count("departements".*),
              "ddfips_count"         = get_departements_ddfips_count("departements".*)
      WHERE   "departements"."id" = NEW."id";

    END IF;

    -- Reset all communes_count, departements_count & collectivities_count
    -- * on creation
    -- * on deletion
    -- * when code_region changed
    -- * when code_departement changed

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."code_region" <> OLD."code_region")
    OR (TG_OP = 'UPDATE' AND NEW."code_departement" <> OLD."code_departement")
    THEN

      UPDATE  "communes"
      SET     "collectivities_count" = get_communes_collectivities_count("communes".*)
      WHERE   "communes"."code_departement" IN (NEW."code_departement", OLD."code_departement");

      UPDATE  "epcis"
      SET     "collectivities_count" = get_epcis_collectivities_count("epcis".*)
      WHERE   "epcis"."siren" IN (
                SELECT "communes"."siren_epci"
                FROM   "communes"
                WHERE  "communes"."code_departement" IN (NEW."code_departement", OLD."code_departement")
              );

      UPDATE  "regions"
      SET     "communes_count"       = get_regions_communes_count("regions".*),
              "epcis_count"          = get_regions_epcis_count("regions".*),
              "departements_count"   = get_regions_departements_count("regions".*),
              "collectivities_count" = get_regions_collectivities_count("regions".*),
              "ddfips_count"         = get_regions_ddfips_count("regions".*)
      WHERE   "regions"."code_region" IN (NEW."code_region", OLD."code_region");

      UPDATE  "ddfips"
      SET     "collectivities_count" = get_ddfips_collectivities_count("ddfips".*)
      WHERE   "ddfips"."code_departement" IN (NEW."code_departement", OLD."code_departement");

    END IF;

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$function$ LANGUAGE plpgsql;

