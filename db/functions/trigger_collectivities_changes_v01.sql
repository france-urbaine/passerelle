CREATE OR REPLACE FUNCTION trigger_collectivities_changes()
RETURNS trigger
AS $function$
  BEGIN
    -- Reset publishers#collectivities_count
    -- * on creation
    -- * on deletion
    -- * when publisher_id changed (could be NULL)
    -- * when discarded_at changed from NULL
    -- * when discarded_at changed to NULL

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."publisher_id" <> OLD."publisher_id")
    OR (TG_OP = 'UPDATE' AND (NEW."publisher_id" IS NULL) <> (OLD."publisher_id" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."discarded_at" IS NULL) <> (OLD."discarded_at" IS NULL))
    THEN

      UPDATE "publishers"
      SET    "collectivities_count" = get_collectivities_count_in_publishers("publishers".*)
      WHERE  "publishers"."id" IN (NEW."publisher_id", OLD."publisher_id");

    END IF;

    -- -- Reset all collectivities_count
    -- -- * on creation
    -- -- * on deletion
    -- -- * when territory_id changed
    -- -- * when discarded_at changed from NULL
    -- -- * when discarded_at changed to NULL

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."territory_id" <> OLD."territory_id")
    OR (TG_OP = 'UPDATE' AND (NEW."discarded_at" IS NULL) <> (OLD."discarded_at" IS NULL))
    THEN

      UPDATE  "communes"
      SET     "collectivities_count" = get_collectivities_count_in_communes("communes".*)
      WHERE   (NEW."territory_type" = 'Commune'     AND "communes"."id" = NEW."territory_id")
        OR    (OLD."territory_type" = 'Commune'     AND "communes"."id" = OLD."territory_id")
        OR    (NEW."territory_type" = 'EPCI'        AND "communes"."siren_epci" IN (SELECT "epcis"."siren" FROM "epcis" WHERE "epcis"."id" = NEW."territory_id"))
        OR    (OLD."territory_type" = 'EPCI'        AND "communes"."siren_epci" IN (SELECT "epcis"."siren" FROM "epcis" WHERE "epcis"."id" = OLD."territory_id"))
        OR    (NEW."territory_type" = 'Departement' AND "communes"."code_departement" IN (SELECT "departements"."code_departement" FROM "departements" WHERE "departements"."id" = NEW."territory_id"))
        OR    (OLD."territory_type" = 'Departement' AND "communes"."code_departement" IN (SELECT "departements"."code_departement" FROM "departements" WHERE "departements"."id" = OLD."territory_id"))
        OR    (NEW."territory_type" = 'Region'      AND "communes"."code_departement" IN (SELECT "departements"."code_departement" FROM "departements" INNER JOIN "regions" ON "regions"."code_region" = "departements"."code_region" WHERE "regions"."id" = NEW."territory_id"))
        OR    (OLD."territory_type" = 'Region'      AND "communes"."code_departement" IN (SELECT "departements"."code_departement" FROM "departements" INNER JOIN "regions" ON "regions"."code_region" = "departements"."code_region" WHERE "regions"."id" = OLD."territory_id"));

      UPDATE  "epcis"
      SET     "collectivities_count" = get_collectivities_count_in_epcis("epcis".*)
      WHERE   (NEW."territory_type" = 'EPCI'        AND "epcis"."id" = NEW."territory_id")
        OR    (OLD."territory_type" = 'EPCI'        AND "epcis"."id" = OLD."territory_id")
        OR    (NEW."territory_type" = 'Commune'     AND "epcis"."siren" IN (SELECT "communes"."siren_epci" FROM "communes" WHERE "communes"."id" = NEW."territory_id"))
        OR    (OLD."territory_type" = 'Commune'     AND "epcis"."siren" IN (SELECT "communes"."siren_epci" FROM "communes" WHERE "communes"."id" = OLD."territory_id"))
        OR    (NEW."territory_type" = 'Departement' AND "epcis"."siren" IN (SELECT "communes"."siren_epci" FROM "communes" INNER JOIN "departements" ON "departements"."code_departement" = "communes"."code_departement" WHERE "departements"."id" = NEW."territory_id"))
        OR    (OLD."territory_type" = 'Departement' AND "epcis"."siren" IN (SELECT "communes"."siren_epci" FROM "communes" INNER JOIN "departements" ON "departements"."code_departement" = "communes"."code_departement" WHERE "departements"."id" = OLD."territory_id"))
        OR    (NEW."territory_type" = 'Region'      AND "epcis"."siren" IN (SELECT "communes"."siren_epci" FROM "communes" INNER JOIN "departements" ON "departements"."code_departement" = "communes"."code_departement" INNER JOIN "regions" ON "regions"."code_region" = "departements"."code_region" WHERE "regions"."id" = NEW."territory_id"))
        OR    (OLD."territory_type" = 'Region'      AND "epcis"."siren" IN (SELECT "communes"."siren_epci" FROM "communes" INNER JOIN "departements" ON "departements"."code_departement" = "communes"."code_departement" INNER JOIN "regions" ON "regions"."code_region" = "departements"."code_region" WHERE "regions"."id" = OLD."territory_id"));

      UPDATE  "departements"
      SET     "collectivities_count" = get_collectivities_count_in_departements("departements".*)
      WHERE   (NEW."territory_type" = 'Departement' AND "departements"."id" = NEW."territory_id")
        OR    (OLD."territory_type" = 'Departement' AND "departements"."id" = OLD."territory_id")
        OR    (NEW."territory_type" = 'Commune'     AND "departements"."code_departement" IN (SELECT "communes"."code_departement" FROM "communes" WHERE "communes"."id" = NEW."territory_id"))
        OR    (OLD."territory_type" = 'Commune'     AND "departements"."code_departement" IN (SELECT "communes"."code_departement" FROM "communes" WHERE "communes"."id" = OLD."territory_id"))
        OR    (NEW."territory_type" = 'EPCI'        AND "departements"."code_departement" IN (SELECT "communes"."code_departement" FROM "communes" INNER JOIN "epcis" ON "epcis"."siren" = "communes"."siren_epci" WHERE "epcis"."id" = NEW."territory_id" ))
        OR    (OLD."territory_type" = 'EPCI'        AND "departements"."code_departement" IN (SELECT "communes"."code_departement" FROM "communes" INNER JOIN "epcis" ON "epcis"."siren" = "communes"."siren_epci" WHERE "epcis"."id" = OLD."territory_id" ))
        OR    (NEW."territory_type" = 'Region'      AND "departements"."code_region" IN (SELECT "regions"."code_region" FROM "regions" WHERE "regions"."id" = NEW."territory_id"))
        OR    (OLD."territory_type" = 'Region'      AND "departements"."code_region" IN (SELECT "regions"."code_region" FROM "regions" WHERE "regions"."id" = OLD."territory_id"));

      UPDATE  "regions"
      SET     "collectivities_count" = get_collectivities_count_in_regions("regions".*)
      WHERE   (NEW."territory_type" = 'Region'      AND "regions"."id" = NEW."territory_id")
        OR    (OLD."territory_type" = 'Region'      AND "regions"."id" = OLD."territory_id")
        OR    (NEW."territory_type" = 'Commune'     AND "regions"."code_region" IN (SELECT "departements"."code_region" FROM "departements" INNER JOIN "communes" ON "communes"."code_departement" = "departements"."code_departement" WHERE "communes"."id" = NEW."territory_id"))
        OR    (OLD."territory_type" = 'Commune'     AND "regions"."code_region" IN (SELECT "departements"."code_region" FROM "departements" INNER JOIN "communes" ON "communes"."code_departement" = "departements"."code_departement" WHERE "communes"."id" = OLD."territory_id"))
        OR    (NEW."territory_type" = 'EPCI'        AND "regions"."code_region" IN (SELECT "departements"."code_region" FROM "departements" INNER JOIN "communes" ON "communes"."code_departement" = "departements"."code_departement" INNER JOIN "epcis" ON "epcis"."siren" = "communes"."siren_epci" WHERE "epcis"."id" = NEW."territory_id"))
        OR    (OLD."territory_type" = 'EPCI'        AND "regions"."code_region" IN (SELECT "departements"."code_region" FROM "departements" INNER JOIN "communes" ON "communes"."code_departement" = "departements"."code_departement" INNER JOIN "epcis" ON "epcis"."siren" = "communes"."siren_epci" WHERE "epcis"."id" = OLD."territory_id"))
        OR    (NEW."territory_type" = 'Departement' AND "regions"."code_region" IN (SELECT "departements"."code_region" FROM "departements" WHERE "departements"."id" = NEW."territory_id"))
        OR    (OLD."territory_type" = 'Departement' AND "regions"."code_region" IN (SELECT "departements"."code_region" FROM "departements" WHERE "departements"."id" = OLD."territory_id"));

      UPDATE  "ddfips"
      SET     "collectivities_count" = get_collectivities_count_in_ddfips("ddfips".*)
      WHERE   (NEW."territory_type" = 'Commune'     AND "ddfips"."code_departement" IN (SELECT "communes"."code_departement" FROM "communes" WHERE  "communes"."id" = NEW."territory_id" ))
        OR    (OLD."territory_type" = 'Commune'     AND "ddfips"."code_departement" IN (SELECT "communes"."code_departement" FROM "communes" WHERE  "communes"."id" = OLD."territory_id" ))
        OR    (NEW."territory_type" = 'EPCI'        AND "ddfips"."code_departement" IN (SELECT "communes"."code_departement" FROM "communes" INNER JOIN "epcis" ON "epcis"."siren" = "communes"."siren_epci" WHERE "epcis"."id" = NEW."territory_id"))
        OR    (OLD."territory_type" = 'EPCI'        AND "ddfips"."code_departement" IN (SELECT "communes"."code_departement" FROM "communes" INNER JOIN "epcis" ON "epcis"."siren" = "communes"."siren_epci" WHERE "epcis"."id" = OLD."territory_id"))
        OR    (NEW."territory_type" = 'Departement' AND "ddfips"."code_departement" IN (SELECT "departements"."code_departement" FROM "departements" WHERE  "departements"."id" = NEW."territory_id"))
        OR    (OLD."territory_type" = 'Departement' AND "ddfips"."code_departement" IN (SELECT "departements"."code_departement" FROM "departements" WHERE  "departements"."id" = OLD."territory_id"))
        OR    (NEW."territory_type" = 'Region'      AND "ddfips"."code_departement" IN (SELECT "departements"."code_departement" FROM "departements" INNER JOIN "regions" ON "regions"."code_region" = "departements"."code_region" WHERE  "regions"."id" = NEW."territory_id"))
        OR    (OLD."territory_type" = 'Region'      AND "ddfips"."code_departement" IN (SELECT "departements"."code_departement" FROM "departements" INNER JOIN "regions" ON "regions"."code_region" = "departements"."code_region" WHERE  "regions"."id" = OLD."territory_id"));

    END IF;

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$function$ LANGUAGE plpgsql;

