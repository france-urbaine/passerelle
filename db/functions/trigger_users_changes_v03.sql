CREATE OR REPLACE FUNCTION trigger_users_changes()
RETURNS trigger
AS $function$
  BEGIN
    -- Reset all users_count
    -- * on creation
    -- * on deletion
    -- * when organization_id changed
    -- * when discarded_at changed from NULL
    -- * when discarded_at changed to NULL

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."organization_id" <> OLD."organization_id")
    OR (TG_OP = 'UPDATE' AND (NEW."discarded_at" IS NULL) <> (OLD."discarded_at" IS NULL))
    THEN

      UPDATE "publishers"
      SET    "users_count" = get_publishers_users_count("publishers".*)
      WHERE  (NEW."organization_type" = 'Publisher' AND "publishers"."id" = NEW."organization_id")
        OR   (OLD."organization_type" = 'Publisher' AND "publishers"."id" = OLD."organization_id");

      UPDATE "collectivities"
      SET    "users_count" = get_collectivities_users_count("collectivities".*)
      WHERE  (NEW."organization_type" = 'Collectivity' AND "collectivities"."id" = NEW."organization_id")
        OR   (OLD."organization_type" = 'Collectivity' AND "collectivities"."id" = OLD."organization_id");

      UPDATE "ddfips"
      SET    "users_count" = get_ddfips_users_count("ddfips".*)
      WHERE  (NEW."organization_type" = 'DDFIP' AND "ddfips"."id" = NEW."organization_id")
        OR   (OLD."organization_type" = 'DDFIP' AND "ddfips"."id" = OLD."organization_id");

      UPDATE "dgfips"
      SET    "users_count" = get_dgfips_users_count("dgfips".*)
      WHERE  (NEW."organization_type" = 'DGFIP' AND "dgfips"."id" = NEW."organization_id")
        OR   (OLD."organization_type" = 'DGFIP' AND "dgfips"."id" = OLD."organization_id");

      UPDATE "offices"
      SET    "users_count" = get_offices_users_count("offices".*)
      WHERE  "offices"."id" IN (
        SELECT "office_users"."office_id"
        FROM   "office_users"
        WHERE  "office_users"."user_id" IN (NEW."id", OLD."id")
      );

    END IF;

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$function$ LANGUAGE plpgsql;

