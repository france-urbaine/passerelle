CREATE OR REPLACE FUNCTION get_publishers_reports_transmitted_count(publishers publishers)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
      WHERE      "packages"."sandbox" = FALSE
        AND      "packages"."discarded_at" IS NULL
        AND      "reports"."discarded_at"  IS NULL
        AND      "reports"."publisher_id" = publishers."id"
    );
  END;
$function$ LANGUAGE plpgsql;
