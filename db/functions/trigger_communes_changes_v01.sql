CREATE OR REPLACE FUNCTION trigger_communes_changes()
RETURNS trigger
AS $function$
  BEGIN
    -- Reset all communes_count & collectivities_count
    -- * on creation
    -- * on deletion
    -- * when code_departement changed
    -- * when siren_epci changed

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."code_departement" <> OLD."code_departement")
    OR (TG_OP = 'UPDATE' AND NEW."siren_epci" <> OLD."siren_epci")
    OR (TG_OP = 'UPDATE' AND (NEW."siren_epci" IS NULL) <> (OLD."siren_epci" IS NULL))
    THEN

      PERFORM reset_all_epcis_counters();
      PERFORM reset_all_departements_counters();
      PERFORM reset_all_regions_counters();
      PERFORM reset_all_ddfips_counters();

    END IF;

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$function$ LANGUAGE plpgsql;

