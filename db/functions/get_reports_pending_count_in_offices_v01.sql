CREATE OR REPLACE FUNCTION get_reports_pending_count_in_offices(offices offices)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
      INNER JOIN "office_communes"
         ON      "office_communes"."code_insee" = "reports"."code_insee"
        AND      "office_communes"."office_id" = offices."id"
      WHERE      ARRAY["reports"."form_type"] <@ offices."competences"
        AND      "reports"."discarded_at" IS NULL
        AND      "packages"."sandbox" = FALSE
        AND      "packages"."transmitted_at" IS NOT NULL
        AND      "packages"."approved_at" IS NULL
        AND      "packages"."rejected_at" IS NULL
        AND      "reports"."debated_at" IS NULL
        AND      "packages"."discarded_at" IS NULL
    );
  END;
$function$ LANGUAGE plpgsql;
