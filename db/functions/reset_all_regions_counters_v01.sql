-- SELECT reset_all_regions_counters();

CREATE OR REPLACE FUNCTION reset_all_regions_counters()
RETURNS integer
AS $function$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "regions"
    SET    "communes_count"       = get_communes_count_in_regions("regions".*),
           "epcis_count"          = get_epcis_count_in_regions("regions".*),
           "departements_count"   = get_departements_count_in_regions("regions".*),
           "ddfips_count"         = get_ddfips_count_in_regions("regions".*),
           "collectivities_count" = get_collectivities_count_in_regions("regions".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$function$ LANGUAGE plpgsql;
