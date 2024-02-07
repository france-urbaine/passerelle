CREATE OR REPLACE FUNCTION get_publishers_reports_rejected_count(publishers publishers)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      WHERE      "reports"."publisher_id" = publishers."id"
        AND      "reports"."discarded_at" IS NULL
        AND      "reports"."sandbox" = FALSE
        AND      "reports"."state" = 'rejected'
    );
  END;
$function$ LANGUAGE plpgsql;
