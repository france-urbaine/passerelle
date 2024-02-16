CREATE OR REPLACE FUNCTION trigger_office_communes_changes()
RETURNS trigger
AS $function$
  BEGIN

    -- Reset communes_count in offices
    -- on every events

    UPDATE  "offices"
    SET     "communes_count" = get_offices_communes_count("offices".*)
    WHERE   "offices"."id" IN (NEW."office_id", OLD."office_id");

    -- Reset offices_count in communes
    -- on every events

    UPDATE  "communes"
    SET     "offices_count" = get_communes_offices_count("communes".*)
    WHERE   "communes"."code_insee" IN (NEW."code_insee", OLD."code_insee");

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$function$ LANGUAGE plpgsql;
