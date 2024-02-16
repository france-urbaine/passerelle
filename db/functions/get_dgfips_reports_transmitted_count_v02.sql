CREATE OR REPLACE FUNCTION get_dgfips_reports_transmitted_count(dgfips dgfips)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "reports"
      WHERE  "reports"."discarded_at" IS NULL
        AND  "reports"."sandbox" = FALSE
        AND  "reports"."state" IN  (
          'transmitted',
          'acknowledged',
          'accepted',
          'assigned',
          'applicable',
          'inapplicable',
          'approved',
          'canceled',
          'rejected'
        )
    );
  END;
$function$ LANGUAGE plpgsql;
