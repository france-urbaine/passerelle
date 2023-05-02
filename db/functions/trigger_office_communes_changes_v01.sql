CREATE OR REPLACE FUNCTION trigger_office_communes_changes()
RETURNS trigger
AS $function$
  BEGIN

    UPDATE  "offices"
    SET     "communes_count" = get_communes_count_in_offices("offices".*)
    WHERE   "offices"."id" IN (NEW."office_id", OLD."office_id");

    UPDATE  "communes"
    SET     "offices_count" = get_offices_count_in_communes("communes".*)
    WHERE   "communes"."code_insee" IN (NEW."code_insee", OLD."code_insee");

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$function$ LANGUAGE plpgsql;

