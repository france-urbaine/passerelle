-- SELECT reset_all_packages_counters();

CREATE OR REPLACE FUNCTION reset_all_packages_counters()
RETURNS integer
AS $function$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "packages"
    SET    "reports_count"           = get_packages_reports_count("packages".*),
           "reports_approved_count"  = get_packages_reports_approved_count("packages".*),
           "reports_rejected_count"  = get_packages_reports_rejected_count("packages".*),
           "reports_debated_count"   = get_packages_reports_debated_count("packages".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$function$ LANGUAGE plpgsql;
