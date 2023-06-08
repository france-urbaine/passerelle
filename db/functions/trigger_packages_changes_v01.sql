CREATE OR REPLACE FUNCTION trigger_packages_changes()
RETURNS trigger
AS $function$
  BEGIN

    -- Reset all packages_count, packages_approved_count, packages_rejected_count
    -- * on deletion
    -- * when approved_at changed
    -- * when rejected_at changed

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."approved_at" <> OLD."approved_at")
    OR (TG_OP = 'UPDATE' AND NEW."rejected_at" <> OLD."rejected_at")
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
