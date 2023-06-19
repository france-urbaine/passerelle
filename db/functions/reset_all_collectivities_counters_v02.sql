-- SELECT reset_all_collectivities_counters();

CREATE OR REPLACE FUNCTION reset_all_collectivities_counters()
RETURNS integer
AS $function$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "collectivities"
    SET    "users_count"             = get_users_count_in_collectivities("collectivities".*),
           "reports_count"           = get_reports_count_in_collectivities("collectivities".*),
           "reports_approved_count"  = get_reports_approved_count_in_collectivities("collectivities".*),
           "reports_rejected_count"  = get_reports_rejected_count_in_collectivities("collectivities".*),
           "reports_debated_count"   = get_reports_debated_count_in_collectivities("collectivities".*),
           "packages_count"          = get_packages_count_in_collectivities("collectivities".*),
           "packages_approved_count" = get_packages_approved_count_in_collectivities("collectivities".*),
           "packages_rejected_count" = get_packages_rejected_count_in_collectivities("collectivities".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$function$ LANGUAGE plpgsql;
