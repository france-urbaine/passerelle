CREATE OR REPLACE FUNCTION trigger_departements_changes()
RETURNS trigger
AS $function$
  BEGIN
    -- Reset all departements_count & collectivities_count
    -- * on creation
    -- * on deletion
    -- * when code_region changed
    -- * when code_departement changed

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."code_region" <> OLD."code_region")
    OR (TG_OP = 'UPDATE' AND NEW."code_departement" <> OLD."code_departement")
    THEN

      PERFORM reset_all_communes_counters();
      PERFORM reset_all_epcis_counters();
      PERFORM reset_all_departements_counters();
      PERFORM reset_all_regions_counters();
      PERFORM reset_all_ddfips_counters();

    END IF;

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$function$ LANGUAGE plpgsql;

