CREATE OR REPLACE FUNCTION get_dgfips_reports_accepted_count(dgfips dgfips)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "reports"
      WHERE  "reports"."discarded_at" IS NULL
        AND  "reports"."sandbox" = FALSE
        AND  "reports"."state" IN  (
          'accepted',
          'assigned',
          'applicable',
          'inapplicable',
          'approved',
          'canceled'
        )
    );
  END;
$function$ LANGUAGE plpgsql;
