-- SELECT reset_all_offices_counters();

CREATE OR REPLACE FUNCTION reset_all_offices_counters()
RETURNS integer
AS $function$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE  "offices"
    SET     "users_count"              = get_offices_users_count("offices".*),
            "communes_count"           = get_offices_communes_count("offices".*),
            "reports_assigned_count"   = get_offices_reports_assigned_count("offices".*),
            "reports_resolved_count"   = get_offices_reports_resolved_count("offices".*),
            "reports_approved_count"   = get_offices_reports_approved_count("offices".*),
            "reports_canceled_count"   = get_offices_reports_canceled_count("offices".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$function$ LANGUAGE plpgsql;
