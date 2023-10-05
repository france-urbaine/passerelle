CREATE OR REPLACE FUNCTION get_dgfips_reports_transmitted_count(dgfips dgfips)
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
    );
  END;
$function$ LANGUAGE plpgsql;
