CREATE OR REPLACE FUNCTION trigger_office_communes_changes()
RETURNS trigger
AS $function$
  BEGIN

    UPDATE  "offices"
    SET     "communes_count"         = get_communes_count_in_offices("offices".*),
            "reports_count"          = get_reports_count_in_offices("offices".*),
            "reports_approved_count" = get_reports_approved_count_in_offices("offices".*),
            "reports_rejected_count" = get_reports_rejected_count_in_offices("offices".*),
            "reports_debated_count"  = get_reports_debated_count_in_offices("offices".*),
            "reports_pending_count"  = get_reports_pending_count_in_offices("offices".*)
    WHERE   "offices"."id" IN (NEW."office_id", OLD."office_id");

    UPDATE  "communes"
    SET     "offices_count" = get_offices_count_in_communes("communes".*)
    WHERE   "communes"."code_insee" IN (NEW."code_insee", OLD."code_insee");

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$function$ LANGUAGE plpgsql;
