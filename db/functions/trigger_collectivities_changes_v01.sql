CREATE OR REPLACE FUNCTION trigger_collectivities_changes()
RETURNS trigger
AS $function$
  BEGIN
    -- Reset all collectivities_count
    -- * on creation
    -- * on deletion
    -- * when territory_id changed
    -- * when discarded_at changed from NULL
    -- * when discarded_at changed to NULL

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."territory_id" <> OLD."territory_id")
    OR (TG_OP = 'UPDATE' AND (NEW."discarded_at" IS NULL) <> (OLD."discarded_at" IS NULL))
    THEN

      PERFORM reset_all_communes_counters();
      PERFORM reset_all_epcis_counters();
      PERFORM reset_all_departements_counters();
      PERFORM reset_all_regions_counters();
      PERFORM reset_all_ddfips_counters();
      PERFORM reset_all_publishers_counters();

    END IF;

    -- Reset publishers#collectivities_count
    -- * on creation
    -- * on deletion
    -- * when publisher_id changed
    -- * when discarded_at changed from NULL
    -- * when discarded_at changed to NULL

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."publisher_id" <> OLD."publisher_id")
    OR (TG_OP = 'UPDATE' AND (NEW."discarded_at" IS NULL) <> (OLD."discarded_at" IS NULL))
    THEN

      PERFORM reset_all_publishers_counters();

    END IF;

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$function$ LANGUAGE plpgsql;

