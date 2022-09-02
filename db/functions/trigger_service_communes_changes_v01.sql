CREATE OR REPLACE FUNCTION trigger_service_communes_changes()
RETURNS trigger
AS $function$
  BEGIN

    UPDATE  "services"
    SET     "communes_count" = get_services_communes_count("services".*)
    WHERE   "services"."id" IN (NEW."service_id", OLD."service_id");

    UPDATE  "communes"
    SET     "services_count" = get_communes_services_count("communes".*)
    WHERE   "communes"."code_insee" IN (NEW."code_insee", OLD."code_insee");

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$function$ LANGUAGE plpgsql;

