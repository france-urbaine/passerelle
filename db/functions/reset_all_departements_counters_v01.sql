-- SELECT reset_all_departements_counters();

CREATE OR REPLACE FUNCTION reset_all_departements_counters()
RETURNS integer
AS $function$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "departements"
    SET    "communes_count"       = get_communes_count_in_departements("departements".*),
           "epcis_count"          = get_epcis_count_in_departements("departements".*),
           "ddfips_count"         = get_ddfips_count_in_departements("departements".*),
           "collectivities_count" = get_collectivities_count_in_departements("departements".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$function$ LANGUAGE plpgsql;
