CREATE OR REPLACE FUNCTION get_publishers_reports_transmitted_count(publishers publishers)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      WHERE      "reports"."publisher_id" = publishers."id"
        AND      "reports"."sandbox" = FALSE
        AND      "reports"."transmitted_at" IS NOT NULL
        AND      "reports"."discarded_at" IS NULL
    );
  END;
$function$ LANGUAGE plpgsql;
