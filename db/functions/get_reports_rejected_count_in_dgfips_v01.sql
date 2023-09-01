CREATE OR REPLACE FUNCTION get_reports_rejected_count_in_dgfips(dgfips dgfips)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "reports"
      INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
      WHERE      "reports"."discarded_at" IS NULL
        AND      "packages"."sandbox" = FALSE
        AND      "packages"."discarded_at" IS NULL
        AND      "packages"."transmitted_at" IS NOT NULL
        AND      "reports"."rejected_at" IS NOT NULL
    );
  END;
$function$ LANGUAGE plpgsql;
