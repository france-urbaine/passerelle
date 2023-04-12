CREATE OR REPLACE FUNCTION get_collectivities_count_in_regions(regions regions)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "collectivities"
      WHERE  "collectivities"."discarded_at" IS NULL AND (
        (
          "collectivities"."territory_type" = 'Region' AND
          "collectivities"."territory_id"   = regions."id"
        ) OR (
          "collectivities"."territory_type" = 'Commune' AND
          "collectivities"."territory_id" IN (
            SELECT     "communes"."id"
            FROM       "communes"
            INNER JOIN "departements" ON "departements"."code_departement" = "communes"."code_departement"
            WHERE      "departements"."code_region" = regions."code_region"
          )
        ) OR (
          "collectivities"."territory_type" = 'EPCI' AND
          "collectivities"."territory_id" IN (
            SELECT     "epcis"."id"
            FROM       "epcis"
            INNER JOIN "communes" ON "communes"."siren_epci" = "epcis"."siren"
            INNER JOIN "departements" ON "departements"."code_departement" = "communes"."code_departement"
            WHERE      "departements"."code_region" = regions."code_region"
          )
        ) OR (
          "collectivities"."territory_type" = 'Departement' AND
          "collectivities"."territory_id" IN (
            SELECT "departements"."id"
            FROM   "departements"
            WHERE  "departements"."code_region" = regions."code_region"
          )
        )
      )
    );
  END;
$function$ LANGUAGE plpgsql;
