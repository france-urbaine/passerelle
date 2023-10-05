-- SELECT reset_all_regions_counters();

CREATE OR REPLACE FUNCTION reset_all_regions_counters()
RETURNS integer
AS $function$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "regions"
    SET    "communes_count"       = get_regions_communes_count("regions".*),
           "epcis_count"          = get_regions_epcis_count("regions".*),
           "departements_count"   = get_regions_departements_count("regions".*),
           "ddfips_count"         = get_regions_ddfips_count("regions".*),
           "collectivities_count" = get_regions_collectivities_count("regions".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$function$ LANGUAGE plpgsql;
