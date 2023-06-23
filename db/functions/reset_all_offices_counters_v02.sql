-- SELECT reset_all_offices_counters();

CREATE OR REPLACE FUNCTION reset_all_offices_counters()
RETURNS integer
AS $function$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "offices"
    SET    "users_count"            = get_users_count_in_offices("offices".*),
           "communes_count"         = get_communes_count_in_offices("offices".*),
           "reports_count"          = get_reports_count_in_offices("offices".*),
           "reports_approved_count" = get_reports_approved_count_in_offices("offices".*),
           "reports_rejected_count" = get_reports_rejected_count_in_offices("offices".*),
           "reports_debated_count"  = get_reports_debated_count_in_offices("offices".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$function$ LANGUAGE plpgsql;
