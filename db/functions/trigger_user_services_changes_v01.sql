CREATE OR REPLACE FUNCTION trigger_user_services_changes()
RETURNS trigger
AS $function$
  BEGIN

    UPDATE  "services"
    SET     "users_count" = get_services_users_count("services".*)
    WHERE   "services"."id" IN (NEW."service_id", OLD."service_id");

    UPDATE  "users"
    SET     "services_count" = get_users_services_count("users".*)
    WHERE   "users"."id" IN (NEW."user_id", OLD."user_id");

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$function$ LANGUAGE plpgsql;

