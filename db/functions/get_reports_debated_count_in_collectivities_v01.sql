CREATE OR REPLACE FUNCTION get_reports_debated_count_in_collectivities(collectivities collectivities)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
      WHERE      "reports"."collectivity_id" = collectivities."id"
        AND      "reports"."discarded_at" IS NULL
        AND      "reports"."debated_at" IS NOT NULL
        AND      "packages"."sandbox" = FALSE
        AND      "packages"."discarded_at" IS NULL
        AND      ("packages"."publisher_id" IS NULL OR "packages"."transmitted_at" IS NOT NULL)
    );
  END;
$function$ LANGUAGE plpgsql;
