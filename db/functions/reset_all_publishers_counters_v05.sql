-- SELECT reset_all_publishers_counters();

CREATE OR REPLACE FUNCTION reset_all_publishers_counters()
RETURNS integer
AS $function$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "publishers"
    SET    "users_count"                = get_publishers_users_count("publishers".*),
           "collectivities_count"       = get_publishers_collectivities_count("publishers".*),
           "packages_transmitted_count" = get_publishers_packages_transmitted_count("publishers".*),
           "packages_assigned_count"    = get_publishers_packages_assigned_count("publishers".*),
           "packages_returned_count"    = get_publishers_packages_returned_count("publishers".*),
           "reports_transmitted_count"  = get_publishers_reports_transmitted_count("publishers".*),
           "reports_approved_count"     = get_publishers_reports_approved_count("publishers".*),
           "reports_rejected_count"     = get_publishers_reports_rejected_count("publishers".*),
           "reports_debated_count"      = get_publishers_reports_debated_count("publishers".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$function$ LANGUAGE plpgsql;
