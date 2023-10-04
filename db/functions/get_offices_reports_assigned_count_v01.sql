CREATE OR REPLACE FUNCTION get_offices_reports_assigned_count(offices offices)
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
        AND      "packages"."sandbox" = FALSE
        AND      "packages"."discarded_at" IS NULL
        AND      "packages"."assigned_at"  IS NOT NULL
        AND      "packages"."returned_at"  IS NULL
        AND      "reports"."discarded_at"  IS NULL
    );
  END;
$function$ LANGUAGE plpgsql;
