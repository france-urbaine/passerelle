CREATE OR REPLACE FUNCTION get_communes_collectivities_count(communes communes)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "collectivities"
      WHERE  "collectivities"."discarded_at" IS NULL AND (
        (
          "collectivities"."territory_type" = 'Commune' AND
          "collectivities"."territory_id"   = communes."id"
        ) OR (
          "collectivities"."territory_type" = 'EPCI' AND
          "collectivities"."territory_id" IN (
            SELECT "epcis"."id"
            FROM   "epcis"
            WHERE  "epcis"."siren" = communes."siren_epci"
          )
        ) OR (
          "collectivities"."territory_type" = 'Departement' AND
          "collectivities"."territory_id" IN (
            SELECT "departements"."id"
            FROM   "departements"
            WHERE  "departements"."code_departement" = communes."code_departement"
          )
        ) OR (
          "collectivities"."territory_type" = 'Region' AND
          "collectivities"."territory_id" IN (
            SELECT     "regions"."id"
            FROM       "regions"
            INNER JOIN "departements" ON "departements"."code_region" = "regions"."code_region"
            WHERE      "departements"."code_departement" = communes."code_departement"
          )
        )
      )
    );
  END;
$function$ LANGUAGE plpgsql;
