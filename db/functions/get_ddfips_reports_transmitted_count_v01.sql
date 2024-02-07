CREATE OR REPLACE FUNCTION get_ddfips_reports_transmitted_count(ddfips ddfips)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "reports"
      WHERE  "reports"."ddfip_id" = ddfips."id"
        AND  "reports"."discarded_at" IS NULL
        AND  "reports"."sandbox" = FALSE
        AND  "reports"."transmitted_at" IS NOT NULL
    );
  END;
$function$ LANGUAGE plpgsql;
