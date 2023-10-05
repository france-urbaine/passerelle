CREATE OR REPLACE FUNCTION get_collectivities_reports_returned_count(collectivities collectivities)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
      WHERE      "packages"."sandbox" = FALSE
        AND      "packages"."discarded_at" IS NULL
        AND      "packages"."returned_at"  IS NOT NULL
        AND      "reports"."discarded_at"  IS NULL
        AND      "reports"."collectivity_id" = collectivities."id"
    );
  END;
$function$ LANGUAGE plpgsql;
