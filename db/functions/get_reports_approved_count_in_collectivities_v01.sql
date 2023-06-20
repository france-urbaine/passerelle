CREATE OR REPLACE FUNCTION get_reports_approved_count_in_collectivities(collectivities collectivities)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
      WHERE      "reports"."collectivity_id" = collectivities."id"
        AND      "reports"."approved_at" IS NOT NULL
        AND      "reports"."discarded_at" IS NULL
        AND      "packages"."sandbox" = FALSE
        AND      "packages"."transmitted_at" IS NOT NULL
        AND      "packages"."discarded_at" IS NULL
    );
  END;
$function$ LANGUAGE plpgsql;
