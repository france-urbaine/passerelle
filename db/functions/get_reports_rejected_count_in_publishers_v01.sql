CREATE OR REPLACE FUNCTION get_reports_rejected_count_in_publishers(publishers publishers)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "reports"
      WHERE  "reports"."publisher_id" = publishers."id"
        AND  "reports"."rejected_at" IS NOT NULL
    );
  END;
$function$ LANGUAGE plpgsql;
