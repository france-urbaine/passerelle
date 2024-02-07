CREATE OR REPLACE FUNCTION get_collectivities_reports_packing_count(collectivities collectivities)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      WHERE      "reports"."collectivity_id" = collectivities."id"
        AND      "reports"."publisher_id" IS NULL
        AND      "reports"."discarded_at" IS NULL
        AND      "reports"."sandbox" = FALSE
        AND      ("reports"."state" = 'draft' OR "reports"."state" = 'ready')
    );
  END;
$function$ LANGUAGE plpgsql;
