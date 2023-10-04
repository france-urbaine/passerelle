-- SELECT reset_all_dgfips_counters();

CREATE OR REPLACE FUNCTION reset_all_dgfips_counters()
RETURNS integer
AS $function$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "dgfips"
    SET    "users_count"                = get_dgfips_users_count("dgfips".*),
           "packages_transmitted_count" = get_dgfips_packages_transmitted_count("dgfips".*),
           "packages_assigned_count"    = get_dgfips_packages_assigned_count("dgfips".*),
           "packages_returned_count"    = get_dgfips_packages_returned_count("dgfips".*),
           "reports_transmitted_count"  = get_dgfips_reports_transmitted_count("dgfips".*),
           "reports_returned_count"     = get_dgfips_reports_returned_count("dgfips".*),
           "reports_pending_count"      = get_dgfips_reports_pending_count("dgfips".*),
           "reports_debated_count"      = get_dgfips_reports_debated_count("dgfips".*),
           "reports_approved_count"     = get_dgfips_reports_approved_count("dgfips".*),
           "reports_rejected_count"     = get_dgfips_reports_rejected_count("dgfips".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$function$ LANGUAGE plpgsql;
