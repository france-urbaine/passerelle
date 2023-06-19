CREATE OR REPLACE FUNCTION trigger_reports_changes()
RETURNS trigger
AS $function$
  BEGIN

    -- Reset all reports counts on packages
    -- * on creation
    -- * on deletion
    -- * when package_id changed
    -- * when completed changed
    -- * when (approved_at|rejected_at|debated_at|discarded_at) changed from NULL
    -- * when (approved_at|rejected_at|debated_at|discarded_at) changed to NULL

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."package_id" <> OLD."package_id")
    OR (TG_OP = 'UPDATE' AND NEW."completed" <> OLD."completed")
    OR (TG_OP = 'UPDATE' AND (NEW."approved_at" IS NULL) <> (OLD."approved_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."rejected_at" IS NULL) <> (OLD."rejected_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."debated_at" IS NULL) <> (OLD."debated_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."discarded_at" IS NULL) <> (OLD."discarded_at" IS NULL))
    THEN

      UPDATE "packages"
      SET    "reports_count"           = get_reports_count_in_packages("packages".*),
             "reports_completed_count" = get_reports_completed_count_in_packages("packages".*),
             "reports_approved_count"  = get_reports_approved_count_in_packages("packages".*),
             "reports_rejected_count"  = get_reports_rejected_count_in_packages("packages".*),
             "reports_debated_count"   = get_reports_debated_count_in_packages("packages".*)
      WHERE  "packages"."id" IN (NEW."package_id", OLD."package_id");

    END IF;

    -- Reset all reports counts on publishers
    -- * on creation
    -- * on deletion
    -- * when publisher_id changed
    -- * when publisher_id changed from NULL
    -- * when publisher_id changed to NULL
    -- * when (approved_at|rejected_at|debated_at|discarded_at) changed from NULL
    -- * when (approved_at|rejected_at|debated_at|discarded_at) changed to NULL

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."publisher_id" <> OLD."publisher_id")
    OR (TG_OP = 'UPDATE' AND (NEW."publisher_id" IS NULL) <> (OLD."publisher_id" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."approved_at" IS NULL) <> (OLD."approved_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."rejected_at" IS NULL) <> (OLD."rejected_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."debated_at" IS NULL) <> (OLD."debated_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."discarded_at" IS NULL) <> (OLD."discarded_at" IS NULL))
    THEN

      UPDATE "publishers"
      SET    "reports_count"           = get_reports_count_in_publishers("publishers".*),
             "reports_approved_count"  = get_reports_approved_count_in_publishers("publishers".*),
             "reports_rejected_count"  = get_reports_rejected_count_in_publishers("publishers".*),
             "reports_debated_count"   = get_reports_debated_count_in_publishers("publishers".*)

      WHERE  "publishers"."id" IN (NEW."publisher_id", OLD."publisher_id");

    END IF;

    -- Reset all reports counts on collectivities
    -- * on creation
    -- * on deletion
    -- * when (publisher_id|approved_at|rejected_at|debated_at|discarded_at) changed from NULL
    -- * when (publisher_id|approved_at|rejected_at|debated_at|discarded_at) changed to NULL

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND (NEW."publisher_id" IS NULL) <> (OLD."publisher_id" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."approved_at" IS NULL) <> (OLD."approved_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."rejected_at" IS NULL) <> (OLD."rejected_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."debated_at" IS NULL) <> (OLD."debated_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."discarded_at" IS NULL) <> (OLD."discarded_at" IS NULL))
    THEN

      UPDATE "collectivities"
      SET    "reports_count"           = get_reports_count_in_collectivities("collectivities".*),
             "reports_approved_count"  = get_reports_approved_count_in_collectivities("collectivities".*),
             "reports_rejected_count"  = get_reports_rejected_count_in_collectivities("collectivities".*),
             "reports_debated_count"   = get_reports_debated_count_in_collectivities("collectivities".*)

      WHERE  "collectivities"."id" IN (NEW."collectivity_id", OLD."collectivity_id");

    END IF;

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$function$ LANGUAGE plpgsql;
