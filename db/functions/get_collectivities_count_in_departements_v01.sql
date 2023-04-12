CREATE OR REPLACE FUNCTION get_collectivities_count_in_departements(departements departements)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "collectivities"
      WHERE  "collectivities"."discarded_at" IS NULL AND (
        (
          "collectivities"."territory_type" = 'Departement' AND
          "collectivities"."territory_id"   = departements."id"
        ) OR (
          "collectivities"."territory_type" = 'Commune' AND
          "collectivities"."territory_id" IN (
            SELECT "communes"."id"
            FROM   "communes"
            WHERE  "communes"."code_departement" = departements."code_departement"
          )
        ) OR (
          "collectivities"."territory_type" = 'EPCI' AND
          "collectivities"."territory_id" IN (
            SELECT     "epcis"."id"
            FROM       "epcis"
            INNER JOIN "communes" ON "communes"."siren_epci" = "epcis"."siren"
            WHERE      "communes"."code_departement" = departements."code_departement"
          )
        ) OR (
          "collectivities"."territory_type" = 'Region' AND
          "collectivities"."territory_id" IN (
            SELECT     "regions"."id"
            FROM       "regions"
            WHERE      "regions"."code_region" = departements."code_region"
          )
        )
      )
    );
  END;
$function$ LANGUAGE plpgsql;
