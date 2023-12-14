CREATE OR REPLACE FUNCTION trigger_office_communes_changes()
RETURNS trigger
AS $function$
  BEGIN

    UPDATE  "offices"
    SET     "communes_count"           = get_offices_communes_count("offices".*),
            "reports_assigned_count"   = get_offices_reports_assigned_count("offices".*),
            "reports_processing_count" = get_offices_reports_processing_count("offices".*),
            "reports_approved_count"   = get_offices_reports_approved_count("offices".*),
            "reports_rejected_count"   = get_offices_reports_rejected_count("offices".*)
    WHERE   "offices"."id" IN (NEW."office_id", OLD."office_id");

    UPDATE  "communes"
    SET     "offices_count" = get_communes_offices_count("communes".*)
    WHERE   "communes"."code_insee" IN (NEW."code_insee", OLD."code_insee");

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$function$ LANGUAGE plpgsql;
