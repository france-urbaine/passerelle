-- SELECT reset_all_regions_counters();

CREATE OR REPLACE FUNCTION reset_all_regions_counters()
RETURNS integer
AS $function$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "regions"
    SET
      "communes_count" = (
        SELECT     COUNT(*)
        FROM       "communes"
        INNER JOIN "departements" ON "departements"."code_departement" = "communes"."code_departement"
        WHERE      "departements"."code_region" = "regions"."code_region"
      ),
      "epcis_count" = (
        SELECT     COUNT(*)
        FROM       "epcis"
        INNER JOIN "departements" ON "departements"."code_departement" = "epcis"."code_departement"
        WHERE      "departements"."code_region" = "regions"."code_region"
      ),
      "departements_count" = (
        SELECT COUNT(*)
        FROM   "departements"
        WHERE  "departements"."code_region" = "regions"."code_region"
      ),
      "ddfips_count" = (
        SELECT     COUNT(*)
        FROM       "ddfips"
        INNER JOIN "departements" ON "departements"."code_departement" = "ddfips"."code_departement"
        WHERE      "departements"."code_region" = "regions"."code_region"
      ),
      "collectivities_count" = (
        SELECT COUNT(*)
        FROM   "collectivities"
        WHERE  "collectivities"."discarded_at" IS NULL AND (
          (
            "collectivities"."territory_type" = 'Region' AND
            "collectivities"."territory_id"   = "regions"."id"
          ) OR (
            "collectivities"."territory_type" = 'Commune' AND
            "collectivities"."territory_id" IN (
              SELECT     "communes"."id"
              FROM       "communes"
              INNER JOIN "departements" ON "departements"."code_departement" = "communes"."code_departement"
              WHERE      "departements"."code_region" = "regions"."code_region"
            )
          ) OR (
            "collectivities"."territory_type" = 'EPCI' AND
            "collectivities"."territory_id" IN (
              SELECT     "epcis"."id"
              FROM       "epcis"
              INNER JOIN "communes" ON "communes"."siren_epci" = "epcis"."siren"
              INNER JOIN "departements" ON "departements"."code_departement" = "communes"."code_departement"
              WHERE      "departements"."code_region" = "regions"."code_region"
            )
          ) OR (
            "collectivities"."territory_type" = 'Departement' AND
            "collectivities"."territory_id" IN (
              SELECT "departements"."id"
              FROM   "departements"
              WHERE  "departements"."code_region" = "regions"."code_region"
            )
          )
        )
      );

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$function$ LANGUAGE plpgsql;
