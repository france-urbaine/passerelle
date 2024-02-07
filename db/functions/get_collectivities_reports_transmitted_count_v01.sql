CREATE OR REPLACE FUNCTION get_collectivities_reports_transmitted_count(collectivities collectivities)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      WHERE      "reports"."collectivity_id" = collectivities."id"
        AND      "reports"."discarded_at" IS NULL
        AND      "reports"."sandbox" = FALSE
        AND      "reports"."transmitted_at" IS NOT NULL
    );
  END;
$function$ LANGUAGE plpgsql;
