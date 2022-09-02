CREATE OR REPLACE FUNCTION trigger_services_changes()
RETURNS trigger
AS $function$
  BEGIN
    -- Reset all services_count
    -- * on creation
    -- * on deletion
    -- * when ddfip changed

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."ddfip_id" <> OLD."ddfip_id")
    THEN

      UPDATE  "ddfips"
      SET     "services_count" = get_ddfips_services_count("ddfips".*)
      WHERE   "ddfips"."id" IN (NEW."ddfip_id", OLD."ddfip_id");

    END IF;

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$function$ LANGUAGE plpgsql;
