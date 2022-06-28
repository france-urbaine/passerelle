-- SELECT reset_all_regions_counters();

CREATE OR REPLACE FUNCTION reset_all_regions_counters()
RETURNS integer
AS $function$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "regions"
    SET    "communes_count"       = count_communes_in_regions("regions".*),
           "epcis_count"          = count_epcis_in_regions("regions".*),
           "departements_count"   = count_departements_in_regions("regions".*),
           "ddfips_count"         = count_ddfips_in_regions("regions".*),
           "collectivities_count" = count_collectivities_in_regions("regions".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$function$ LANGUAGE plpgsql;
