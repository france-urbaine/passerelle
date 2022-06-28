-- SELECT name, count_collectivities_in_epcis("epcis".*) FROM "epcis";

CREATE OR REPLACE FUNCTION count_collectivities_in_epcis(epcis)
RETURNS integer
AS $function$
  DECLARE
    total integer DEFAULT 0;
  BEGIN
    SELECT COUNT(*) INTO total
    FROM   "collectivities"
    WHERE  "collectivities"."discarded_at" IS NULL AND (
      (
        "collectivities"."territory_type" = 'EPCI' AND
        "collectivities"."territory_id"   = $1."id"
      ) OR (
        "collectivities"."territory_type" = 'Commune' AND
        "collectivities"."territory_id" IN (
          SELECT "communes"."id"
          FROM   "communes"
          WHERE  "communes"."siren_epci" = $1."siren"
        )
      ) OR (
        "collectivities"."territory_type" = 'Departement' AND
        "collectivities"."territory_id" IN (
          SELECT     "departements"."id"
          FROM       "departements"
          INNER JOIN "communes" ON "communes"."code_departement" = "departements"."code_departement"
          WHERE      "communes"."siren_epci" = $1."siren"
        )
      ) OR (
        "collectivities"."territory_type" = 'Region' AND
        "collectivities"."territory_id" IN (
          SELECT     "regions"."id"
          FROM       "regions"
          INNER JOIN "departements" ON "departements"."code_region" = "regions"."code_region"
          INNER JOIN "communes"     ON "communes"."code_departement" = "departements"."code_departement"
          WHERE      "communes"."siren_epci" = $1."siren"
        )
      )
    );

    RETURN total;
  END;
$function$ LANGUAGE plpgsql;
