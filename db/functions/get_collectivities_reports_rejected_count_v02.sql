CREATE OR REPLACE FUNCTION get_collectivities_reports_rejected_count(collectivities collectivities)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      WHERE      "reports"."collectivity_id" = collectivities."id"
        AND      "reports"."discarded_at" IS NULL
        AND      "reports"."sandbox" = FALSE
        AND      "reports"."state" = 'rejected'
    );
  END;
$function$ LANGUAGE plpgsql;
