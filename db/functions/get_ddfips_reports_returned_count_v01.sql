CREATE OR REPLACE FUNCTION get_ddfips_reports_returned_count(ddfips ddfips)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
      INNER JOIN "communes" ON "communes"."code_insee" = "reports"."code_insee"
      WHERE      "communes"."code_departement" = ddfips."code_departement"
        AND      "packages"."sandbox" = FALSE
        AND      "packages"."discarded_at" IS NULL
        AND      "packages"."returned_at"  IS NOT NULL
        AND      "reports"."discarded_at"  IS NULL
    );
  END;
$function$ LANGUAGE plpgsql;
