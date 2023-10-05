CREATE OR REPLACE FUNCTION get_ddfips_packages_unresolved_count(ddfips ddfips)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "packages"
      WHERE  "packages"."sandbox" = FALSE
        AND  "packages"."discarded_at" IS NULL
        AND  "packages"."assigned_at"  IS NULL
        AND  "packages"."returned_at"  IS NULL
        AND  "packages"."id" IN (
                SELECT     "reports"."package_id"
                FROM       "reports"
                INNER JOIN "communes" ON "communes"."code_insee" = "reports"."code_insee"
                WHERE      "communes"."code_departement" = ddfips."code_departement"
             )
    );
  END;
$function$ LANGUAGE plpgsql;
