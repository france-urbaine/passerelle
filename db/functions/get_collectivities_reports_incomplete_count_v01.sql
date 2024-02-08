CREATE OR REPLACE FUNCTION get_collectivities_reports_incomplete_count(collectivities collectivities)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "reports"
      WHERE  "reports"."collectivity_id" = collectivities."id"
        AND  "reports"."state" = 'draft'
        AND  "reports"."ready_at" IS NULL
        AND  "reports"."discarded_at" IS NULL
        AND  "reports"."sandbox" = FALSE
      );
  END;
$function$ LANGUAGE plpgsql;
