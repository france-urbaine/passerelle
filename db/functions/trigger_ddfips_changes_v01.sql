CREATE OR REPLACE FUNCTION trigger_ddfips_changes()
RETURNS trigger
AS $function$
  BEGIN
    -- Reset all ddfips_count
    -- * on creation
    -- * on deletion
    -- * when code_departement changed
    -- * when discarded_at changed from NULL
    -- * when discarded_at changed to NULL

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."code_departement" <> OLD."code_departement")
    OR (TG_OP = 'UPDATE' AND (NEW."discarded_at" IS NULL) <> (OLD."discarded_at" IS NULL))
    THEN

      PERFORM reset_all_departements_counters();
      PERFORM reset_all_regions_counters();

    END IF;

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$function$ LANGUAGE plpgsql;

