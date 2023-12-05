-- SELECT reset_all_collectivities_counters();

CREATE OR REPLACE FUNCTION reset_all_collectivities_counters()
RETURNS integer
AS $function$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "collectivities"
    SET    "users_count"                = get_collectivities_users_count("collectivities".*),
           "reports_incomplete_count"   = get_collectivities_reports_incomplete_count("collectivities".*),
           "reports_packing_count"      = get_collectivities_reports_packing_count("collectivities".*),
           "reports_transmitted_count"  = get_collectivities_reports_transmitted_count("collectivities".*),
           "reports_denied_count"       = get_collectivities_reports_denied_count("collectivities".*),
           "reports_processing_count"   = get_collectivities_reports_processing_count("collectivities".*),
           "reports_approved_count"     = get_collectivities_reports_approved_count("collectivities".*),
           "reports_rejected_count"     = get_collectivities_reports_rejected_count("collectivities".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$function$ LANGUAGE plpgsql;
