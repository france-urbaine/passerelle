-- SELECT reset_all_departements_counters();

CREATE OR REPLACE FUNCTION reset_all_departements_counters()
RETURNS integer
AS $function$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "departements"
    SET    "communes_count"       = get_departements_communes_count("departements".*),
           "epcis_count"          = get_departements_epcis_count("departements".*),
           "ddfips_count"         = get_departements_ddfips_count("departements".*),
           "collectivities_count" = get_departements_collectivities_count("departements".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$function$ LANGUAGE plpgsql;
