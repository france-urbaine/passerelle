-- SELECT reset_all_departements_counters();

CREATE OR REPLACE FUNCTION reset_all_departements_counters()
RETURNS integer
AS $function$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "departements"
    SET
      "communes_count" = (
        SELECT COUNT(*)
        FROM   "communes"
        WHERE  "communes"."code_departement" = "departements"."code_departement"
      ),
      "epcis_count" = (
        SELECT COUNT(*)
        FROM   "epcis"
        WHERE  "epcis"."code_departement" = "departements"."code_departement"
      ),
      "ddfips_count" = (
        SELECT COUNT(*)
        FROM   "ddfips"
        WHERE  "ddfips"."code_departement" = "departements"."code_departement"
      ),
      "collectivities_count" = (
        SELECT COUNT(*)
        FROM   "collectivities"
        WHERE  "collectivities"."discarded_at" IS NULL AND (
          (
            "collectivities"."territory_type" = 'Departement' AND
            "collectivities"."territory_id"   = "departements"."id"
          ) OR (
            "collectivities"."territory_type" = 'Commune' AND
            "collectivities"."territory_id" IN (
              SELECT "communes"."id"
              FROM   "communes"
              WHERE  "communes"."code_departement" = "departements"."code_departement"
            )
          ) OR (
            "collectivities"."territory_type" = 'EPCI' AND
            "collectivities"."territory_id" IN (
              SELECT     "epcis"."id"
              FROM       "epcis"
              INNER JOIN "communes" ON "communes"."siren_epci" = "epcis"."siren"
              WHERE      "communes"."code_departement" = "departements"."code_departement"
            )
          ) OR (
            "collectivities"."territory_type" = 'Region' AND
            "collectivities"."territory_id" IN (
              SELECT     "regions"."id"
              FROM       "regions"
              WHERE      "regions"."code_region" = "departements"."code_region"
            )
          )
        )
      );

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$function$ LANGUAGE plpgsql;
