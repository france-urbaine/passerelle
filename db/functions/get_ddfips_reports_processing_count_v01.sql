CREATE OR REPLACE FUNCTION get_ddfips_reports_processing_count(ddfips ddfips)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "reports"
      WHERE  "reports"."ddfip_id" = ddfips."id"
        AND  "reports"."sandbox" = FALSE
        AND  "reports"."discarded_at" IS NULL
        AND  "reports"."state" = 'processing'
    );
  END;
$function$ LANGUAGE plpgsql;
