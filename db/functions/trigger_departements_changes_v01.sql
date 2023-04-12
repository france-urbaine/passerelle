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
      SET     "communes_count"       = get_communes_count_in_departements("departements".*),
              "epcis_count"          = get_epcis_count_in_departements("departements".*),
              "collectivities_count" = get_collectivities_count_in_departements("departements".*),
              "ddfips_count"         = get_ddfips_count_in_departements("departements".*)
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
      SET     "collectivities_count" = get_collectivities_count_in_communes("communes".*)
      WHERE   "communes"."code_departement" IN (NEW."code_departement", OLD."code_departement");

      UPDATE  "epcis"
      SET     "collectivities_count" = get_collectivities_count_in_epcis("epcis".*)
      WHERE   "epcis"."siren" IN (
                SELECT "communes"."siren_epci"
                FROM   "communes"
                WHERE  "communes"."code_departement" IN (NEW."code_departement", OLD."code_departement")
              );

      UPDATE  "regions"
      SET     "communes_count"       = get_communes_count_in_regions("regions".*),
              "epcis_count"          = get_epcis_count_in_regions("regions".*),
              "departements_count"   = get_departements_count_in_regions("regions".*),
              "collectivities_count" = get_collectivities_count_in_regions("regions".*),
              "ddfips_count"         = get_ddfips_count_in_regions("regions".*)
      WHERE   "regions"."code_region" IN (NEW."code_region", OLD."code_region");

      UPDATE  "ddfips"
      SET     "collectivities_count" = get_collectivities_count_in_ddfips("ddfips".*)
      WHERE   "ddfips"."code_departement" IN (NEW."code_departement", OLD."code_departement");

    END IF;

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$function$ LANGUAGE plpgsql;

