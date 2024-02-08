CREATE OR REPLACE FUNCTION trigger_office_users_changes()
RETURNS trigger
AS $function$
  BEGIN

    UPDATE  "offices"
    SET     "users_count" = get_offices_users_count("offices".*)
    WHERE   "offices"."id" IN (NEW."office_id", OLD."office_id");

    UPDATE  "users"
    SET     "offices_count" = get_users_offices_count("users".*)
    WHERE   "users"."id" IN (NEW."user_id", OLD."user_id");

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$function$ LANGUAGE plpgsql;

