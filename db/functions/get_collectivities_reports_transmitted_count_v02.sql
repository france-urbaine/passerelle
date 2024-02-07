CREATE OR REPLACE FUNCTION get_collectivities_reports_transmitted_count(collectivities collectivities)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "reports"
      WHERE  "reports"."collectivity_id" = collectivities."id"
        AND  "reports"."discarded_at" IS NULL
        AND  "reports"."sandbox" = FALSE
        AND  "reports"."state" IN (
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
