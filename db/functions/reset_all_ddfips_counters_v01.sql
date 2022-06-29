-- SELECT reset_all_ddfips_counters();

CREATE OR REPLACE FUNCTION reset_all_ddfips_counters()
RETURNS integer
AS $function$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "ddfips"
    SET
      "users_count" = (
        SELECT COUNT(*)
        FROM   "users"
        WHERE  "users"."organization_type" = 'DDFIP'
          AND  "users"."organization_id"   = "ddfips"."id"
      ),
      "collectivities_count" = (
        SELECT COUNT(*)
        FROM   "collectivities"
        WHERE  "collectivities"."discarded_at" IS NULL AND (
          (
            "collectivities"."territory_type" = 'Commune' AND
            "collectivities"."territory_id" IN (
              SELECT "communes"."id"
              FROM   "communes"
              WHERE  "communes"."code_departement" = "ddfips"."code_departement"
            )
          ) OR (
            "collectivities"."territory_type" = 'EPCI' AND
            "collectivities"."territory_id" IN (
              SELECT     "epcis"."id"
              FROM       "epcis"
              INNER JOIN "communes" ON "communes"."siren_epci" = "epcis"."siren"
              WHERE      "communes"."code_departement" = "ddfips"."code_departement"
            )
          ) OR (
            "collectivities"."territory_type" = 'Departement' AND
            "collectivities"."territory_id" IN (
              SELECT "departements"."id"
              FROM   "departements"
              WHERE  "departements"."code_departement" = "ddfips"."code_departement"
            )
          ) OR (
            "collectivities"."territory_type" = 'Region' AND
            "collectivities"."territory_id" IN (
              SELECT     "regions"."id"
              FROM       "regions"
              INNER JOIN "departements" ON "departements"."code_region" = "regions"."code_region"
              WHERE      "departements"."code_departement" = "ddfips"."code_departement"
            )
          )
        )
      );

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$function$ LANGUAGE plpgsql;
