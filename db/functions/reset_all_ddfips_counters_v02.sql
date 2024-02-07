-- SELECT reset_all_ddfips_counters();

CREATE OR REPLACE FUNCTION reset_all_ddfips_counters()
RETURNS integer
AS $function$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE  "ddfips"
    SET     "users_count"               = get_ddfips_users_count("ddfips".*),
            "collectivities_count"      = get_ddfips_collectivities_count("ddfips".*),
            "offices_count"             = get_ddfips_offices_count("ddfips".*),
            "reports_transmitted_count" = get_ddfips_reports_transmitted_count("ddfips".*),
            "reports_unassigned_count"  = get_ddfips_reports_unassigned_count("ddfips".*),
            "reports_accepted_count"    = get_ddfips_reports_accepted_count("ddfips".*),
            "reports_rejected_count"    = get_ddfips_reports_rejected_count("ddfips".*),
            "reports_approved_count"    = get_ddfips_reports_approved_count("ddfips".*),
            "reports_canceled_count"    = get_ddfips_reports_canceled_count("ddfips".*),
            "reports_returned_count"    = get_ddfips_reports_returned_count("ddfips".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$function$ LANGUAGE plpgsql;
