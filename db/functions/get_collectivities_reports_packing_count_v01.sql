CREATE OR REPLACE FUNCTION get_collectivities_reports_packing_count(collectivities collectivities)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      WHERE      "reports"."discarded_at" IS NULL
        AND      "reports"."package_id"   IS NULL
        AND      "reports"."publisher_id" IS NULL
        AND      "reports"."collectivity_id" = collectivities."id"
    );
  END;
$function$ LANGUAGE plpgsql;
