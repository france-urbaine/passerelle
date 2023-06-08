CREATE OR REPLACE FUNCTION trigger_reports_changes()
RETURNS trigger
AS $function$
  BEGIN

    -- Reset all reports_count, reports_completed_count, reports_approved_count, reports_rejected_count & reports_debated_count & completed
    -- * on creation
    -- * on creation
    -- * on deletion
    -- * when completed changed
    -- * when approved_at changed
    -- * when rejected_at changed
    -- * when debated_at changed
    -- * when package_id changed

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."completed" <> OLD."completed")
    OR (TG_OP = 'UPDATE' AND NEW."approved_at" <> OLD."approved_at")
    OR (TG_OP = 'UPDATE' AND NEW."rejected_at" <> OLD."rejected_at")
    OR (TG_OP = 'UPDATE' AND NEW."debated_at" <> OLD."debated_at")
    OR (TG_OP = 'UPDATE' AND NEW."package_id" <> OLD."package_id")
    THEN

      UPDATE "packages"
      SET    "reports_count"           = get_reports_count_in_packages("packages".*),
             "reports_completed_count" = get_reports_completed_count_in_packages("packages".*),
             "reports_approved_count"  = get_reports_approved_count_in_packages("packages".*),
             "reports_rejected_count"  = get_reports_rejected_count_in_packages("packages".*),
             "reports_debated_count"   = get_reports_debated_count_in_packages("packages".*),
             "completed"               = CASE
                                           WHEN "reports_count" = "reports_approved_count" THEN TRUE
                                           ELSE FALSE
                                         END
      WHERE  "packages"."id" IN (NEW."package_id", OLD."package_id");

      UPDATE "publishers"
      SET    "reports_count"           = get_reports_count_in_publishers("publishers".*),
             "reports_completed_count" = get_reports_completed_count_in_publishers("publishers".*),
             "reports_approved_count"  = get_reports_approved_count_in_publishers("publishers".*),
             "reports_rejected_count"  = get_reports_rejected_count_in_publishers("publishers".*),
             "reports_debated_count"   = get_reports_debated_count_in_publishers("publishers".*)
      WHERE  "publishers"."id" IN (NEW."publisher_id", OLD."publisher_id");

    END IF;

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$function$ LANGUAGE plpgsql;
