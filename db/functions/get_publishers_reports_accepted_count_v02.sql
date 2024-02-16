CREATE OR REPLACE FUNCTION get_publishers_reports_accepted_count(publishers publishers)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "reports"
      WHERE  "reports"."publisher_id" = publishers."id"
        AND  "reports"."discarded_at" IS NULL
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
