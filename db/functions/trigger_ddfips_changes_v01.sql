CREATE OR REPLACE FUNCTION trigger_ddfips_changes()
RETURNS trigger
AS $function$
  BEGIN
    -- Reset self ddfips#collectivities_count
    -- * on creation
    -- * when code_departement changed

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'UPDATE' AND NEW."code_departement" <> OLD."code_departement")
    THEN

      UPDATE "ddfips"
      SET    "collectivities_count" = get_ddfips_collectivities_count("ddfips".*)
      WHERE  "ddfips"."id" = NEW."id";

    END IF;

    -- Reset all ddfips_count
    -- * on creation
    -- * on deletion
    -- * when code_departement changed
    -- * when discarded_at changed from NULL
    -- * when discarded_at changed to NULL

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."code_departement" <> OLD."code_departement")
    OR (TG_OP = 'UPDATE' AND (NEW."discarded_at" IS NULL) <> (OLD."discarded_at" IS NULL))
    THEN

      UPDATE  "departements"
      SET     "ddfips_count" = get_departements_ddfips_count("departements".*)
      WHERE   "departements"."code_departement" IN (NEW."code_departement", OLD."code_departement");

      UPDATE  "regions"
      SET     "ddfips_count" = get_regions_ddfips_count("regions".*)
      WHERE   "regions"."code_region" IN (
                SELECT "departements"."code_region"
                FROM   "departements"
                WHERE  "departements"."code_departement" IN (NEW."code_departement", OLD."code_departement")
              );

    END IF;

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$function$ LANGUAGE plpgsql;
