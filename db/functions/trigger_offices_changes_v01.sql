CREATE OR REPLACE FUNCTION trigger_offices_changes()
RETURNS trigger
AS $function$
  BEGIN
    -- Reset all offices_count
    -- * on creation
    -- * on deletion
    -- * when ddfip changed

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."ddfip_id" <> OLD."ddfip_id")
    THEN

      UPDATE  "ddfips"
      SET     "offices_count" = get_offices_count_in_ddfips("ddfips".*)
      WHERE   "ddfips"."id" IN (NEW."ddfip_id", OLD."ddfip_id");

    END IF;

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$function$ LANGUAGE plpgsql;
