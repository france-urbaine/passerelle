-- SELECT name, count_collectivities_in_communes("communes".*) FROM "communes";

CREATE OR REPLACE FUNCTION count_collectivities_in_communes(communes)
RETURNS integer
AS $function$
  DECLARE
    total integer DEFAULT 0;
  BEGIN
    SELECT COUNT(*) INTO total
    FROM   "collectivities"
    WHERE  "collectivities"."discarded_at" IS NULL AND (
      (
        "collectivities"."territory_type" = 'Commune' AND
        "collectivities"."territory_id"   = $1."id"
      ) OR (
        "collectivities"."territory_type" = 'EPCI' AND
        "collectivities"."territory_id" IN (
          SELECT "epcis"."id"
          FROM   "epcis"
          WHERE  "epcis"."siren" = $1."siren_epci"
        )
      ) OR (
        "collectivities"."territory_type" = 'Departement' AND
        "collectivities"."territory_id" IN (
          SELECT "departements"."id"
          FROM   "departements"
          WHERE  "departements"."code_departement" = $1."code_departement"
        )
      ) OR (
        "collectivities"."territory_type" = 'Region' AND
        "collectivities"."territory_id" IN (
          SELECT     "regions"."id"
          FROM       "regions"
          INNER JOIN "departements" ON "departements"."code_region" = "regions"."code_region"
          WHERE      "departements"."code_departement" = $1."code_departement"
        )
      )
    );

    RETURN total;
  END;
$function$ LANGUAGE plpgsql;
