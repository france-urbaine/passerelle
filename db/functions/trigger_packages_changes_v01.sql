CREATE OR REPLACE FUNCTION trigger_packages_changes()
RETURNS trigger
AS $function$
  BEGIN

     -- Reset all completed
    -- * on creation
    -- * on deletion
    -- * when reports_count or reports_completed_count changed

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."reports_count" <> OLD."reports_count")
    OR (TG_OP = 'UPDATE' AND NEW."reports_completed_count" <> OLD."reports_completed_count")
    THEN

      UPDATE "packages"
      SET    "completed" = (NEW."reports_count" = NEW."reports_completed_count")
      WHERE  "packages"."id" IN (NEW."id", OLD."id");

    END IF;

    -- Reset all packages count
    -- * on creation
    -- * on deletion
    -- * when publisher_id changed
    -- * when approved_at or rejected_at changed from NULL
    -- * when approved_at or rejected_at changed to NULL

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND (NEW."approved_at" IS NULL) <> (OLD."approved_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."rejected_at" IS NULL) <> (OLD."rejected_at" IS NULL))
    THEN

      UPDATE "publishers"
      SET    "packages_count"          = get_packages_count_in_publishers("publishers".*),
             "packages_approved_count" = get_packages_approved_count_in_publishers("publishers".*),
             "packages_rejected_count" = get_packages_rejected_count_in_publishers("publishers".*)
      WHERE  "publishers"."id" IN (NEW."publisher_id", OLD."publisher_id");

    END IF;

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$function$ LANGUAGE plpgsql;
