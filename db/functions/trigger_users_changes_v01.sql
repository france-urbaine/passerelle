CREATE OR REPLACE FUNCTION trigger_users_changes()
RETURNS trigger
AS $function$
  BEGIN
    -- Reset all departements_count & collectivities_count
    -- * on creation
    -- * on deletion
    -- * when organization_id changed

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."organization_id" <> OLD."organization_id")
    THEN

      PERFORM reset_all_publishers_counters();
      PERFORM reset_all_collectivities_counters();
      PERFORM reset_all_ddfips_counters();

    END IF;

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$function$ LANGUAGE plpgsql;

