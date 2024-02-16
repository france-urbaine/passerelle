CREATE OR REPLACE FUNCTION get_dgfips_reports_canceled_count(dgfips dgfips)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "reports"
      WHERE  "reports"."discarded_at" IS NULL
        AND  "reports"."sandbox" = FALSE
        AND  "reports"."state" = 'canceled'
    );
  END;
$function$ LANGUAGE plpgsql;
