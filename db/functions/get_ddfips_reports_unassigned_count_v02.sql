CREATE OR REPLACE FUNCTION get_ddfips_reports_unassigned_count(ddfips ddfips)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "reports"
      WHERE  "reports"."ddfip_id" = ddfips."id"
        AND  "reports"."discarded_at" IS NULL
        AND  "reports"."sandbox" = FALSE
        AND  "reports"."state" IN  (
          'transmitted',
          'acknowledged',
          'accepted'
        )
    );
  END;
$function$ LANGUAGE plpgsql;
