-- SELECT reset_all_communes_counters();

CREATE OR REPLACE FUNCTION reset_all_communes_counters()
RETURNS integer
AS $function$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "communes"
    SET    "collectivities_count"  = get_communes_collectivities_count("communes".*),
           "offices_count"         = get_communes_offices_count("communes".*),
           "arrondissements_count" = get_communes_arrondissements_count("communes".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$function$ LANGUAGE plpgsql;
