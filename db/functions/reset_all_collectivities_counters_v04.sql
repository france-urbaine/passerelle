-- SELECT reset_all_collectivities_counters();

CREATE OR REPLACE FUNCTION reset_all_collectivities_counters()
RETURNS integer
AS $function$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "collectivities"
    SET    "users_count"                = get_users_count_in_collectivities("collectivities".*),
           "reports_transmitted_count"  = get_reports_transmitted_count_in_collectivities("collectivities".*),
           "reports_approved_count"     = get_reports_approved_count_in_collectivities("collectivities".*),
           "reports_rejected_count"     = get_reports_rejected_count_in_collectivities("collectivities".*),
           "reports_debated_count"      = get_reports_debated_count_in_collectivities("collectivities".*),
           "packages_transmitted_count" = get_packages_transmitted_count_in_collectivities("collectivities".*),
           "packages_assigned_count"    = get_packages_assigned_count_in_collectivities("collectivities".*),
           "packages_returned_count"    = get_packages_returned_count_in_collectivities("collectivities".*),
           "reports_packing_count"      = get_reports_packing_count_in_collectivities("collectivities".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$function$ LANGUAGE plpgsql;
