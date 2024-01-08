-- SELECT reset_all_offices_counters();

CREATE OR REPLACE FUNCTION reset_all_offices_counters()
RETURNS integer
AS $function$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "offices"
    SET    "users_count"              = get_offices_users_count("offices".*),
           "communes_count"           = get_offices_communes_count("offices".*),
           "reports_assigned_count"   = get_offices_reports_assigned_count("offices".*),
           "reports_processing_count" = get_offices_reports_processing_count("offices".*),
           "reports_approved_count"   = get_offices_reports_approved_count("offices".*),
           "reports_rejected_count"   = get_offices_reports_rejected_count("offices".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$function$ LANGUAGE plpgsql;
