CREATE OR REPLACE FUNCTION get_reports_debated_count_in_publishers(publishers publishers)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "reports"
      WHERE  "reports"."publisher_id" = publishers."id"
        AND  "reports"."debated_at" IS NOT NULL
    );
  END;
$function$ LANGUAGE plpgsql;
