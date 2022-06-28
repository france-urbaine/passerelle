-- SELECT reset_all_departements_counters();

CREATE OR REPLACE FUNCTION reset_all_departements_counters()
RETURNS integer
AS $function$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "departements"
    SET    "communes_count"       = count_communes_in_departements("departements".*),
           "epcis_count"          = count_epcis_in_departements("departements".*),
           "ddfips_count"         = count_ddfips_in_departements("departements".*),
           "collectivities_count" = count_collectivities_in_departements("departements".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$function$ LANGUAGE plpgsql;
