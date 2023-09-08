CREATE OR REPLACE FUNCTION get_reports_packing_count_in_collectivities(collectivities collectivities)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
      WHERE      "packages"."collectivity_id" = collectivities."id"
        AND      "reports"."discarded_at" IS NULL
        AND      "packages"."sandbox" = FALSE
        AND      "packages"."publisher_id" IS NULL
        AND      "packages"."transmitted_at" IS NULL
        AND      "packages"."discarded_at" IS NULL
    );
  END;
$function$ LANGUAGE plpgsql;
