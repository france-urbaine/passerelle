-- SELECT reset_all_publishers_counters();

CREATE OR REPLACE FUNCTION reset_all_publishers_counters()
RETURNS integer
AS $function$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "publishers"
    SET    "users_count"             = get_users_count_in_publishers("publishers".*),
           "collectivities_count"    = get_collectivities_count_in_publishers("publishers".*),
           "reports_count"           = get_reports_count_in_publishers("publishers".*),
           "reports_completed_count" = get_reports_completed_count_in_publishers("publishers".*),
           "reports_approved_count"  = get_reports_approved_count_in_publishers("publishers".*),
           "reports_rejected_count"  = get_reports_rejected_count_in_publishers("publishers".*),
           "reports_debated_count"   = get_reports_debated_count_in_publishers("publishers".*),
           "packages_count"          = get_packages_count_in_publishers("publishers".*),
           "packages_approved_count" = get_packages_approved_count_in_publishers("publishers".*),
           "packages_rejected_count" = get_packages_rejected_count_in_publishers("publishers".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$function$ LANGUAGE plpgsql;
