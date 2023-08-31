-- SELECT reset_all_ddfips_counters();

CREATE OR REPLACE FUNCTION reset_all_ddfips_counters()
RETURNS integer
AS $function$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "ddfips"
    SET    "users_count"            = get_users_count_in_ddfips("ddfips".*),
           "collectivities_count"   = get_collectivities_count_in_ddfips("ddfips".*),
           "offices_count"          = get_offices_count_in_ddfips("ddfips".*),
           "reports_count"          = get_reports_count_in_ddfips("ddfips".*),
           "reports_approved_count" = get_reports_approved_count_in_ddfips("ddfips".*),
           "reports_rejected_count" = get_reports_rejected_count_in_ddfips("ddfips".*),
           "reports_debated_count"  = get_reports_debated_count_in_ddfips("ddfips".*),
           "reports_pending_count"  = get_reports_pending_count_in_ddfips("ddfips".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$function$ LANGUAGE plpgsql;
