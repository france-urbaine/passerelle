CREATE OR REPLACE FUNCTION trigger_office_users_changes()
RETURNS trigger
AS $function$
  BEGIN

    UPDATE  "offices"
    SET     "users_count" = get_users_count_in_offices("offices".*)
    WHERE   "offices"."id" IN (NEW."office_id", OLD."office_id");

    UPDATE  "users"
    SET     "offices_count" = get_offices_count_in_users("users".*)
    WHERE   "users"."id" IN (NEW."user_id", OLD."user_id");

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$function$ LANGUAGE plpgsql;

