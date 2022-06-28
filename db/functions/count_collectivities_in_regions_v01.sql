-- SELECT name, count_collectivities_in_regions("regions".*) FROM "regions";

CREATE OR REPLACE FUNCTION count_collectivities_in_regions(regions)
RETURNS integer
AS $function$
  DECLARE
    total integer DEFAULT 0;
  BEGIN
    SELECT COUNT(*) INTO total
    FROM   "collectivities"
    WHERE  "collectivities"."discarded_at" IS NULL AND (
      (
        "collectivities"."territory_type" = 'Region' AND
        "collectivities"."territory_id"   = $1."id"
      ) OR (
        "collectivities"."territory_type" = 'Commune' AND
        "collectivities"."territory_id" IN (
          SELECT     "communes"."id"
          FROM       "communes"
          INNER JOIN "departements" ON "departements"."code_departement" = "communes"."code_departement"
          WHERE      "departements"."code_region" = $1."code_region"
        )
      ) OR (
        "collectivities"."territory_type" = 'EPCI' AND
        "collectivities"."territory_id" IN (
          SELECT     "epcis"."id"
          FROM       "epcis"
          INNER JOIN "communes" ON "communes"."siren_epci" = "epcis"."siren"
          INNER JOIN "departements" ON "departements"."code_departement" = "communes"."code_departement"
          WHERE      "departements"."code_region" = $1."code_region"
        )
      ) OR (
        "collectivities"."territory_type" = 'Departement' AND
        "collectivities"."territory_id" IN (
          SELECT "departements"."id"
          FROM   "departements"
          WHERE  "departements"."code_region" = $1."code_region"
        )
      )
    );

    RETURN total;
  END;
$function$ LANGUAGE plpgsql;
