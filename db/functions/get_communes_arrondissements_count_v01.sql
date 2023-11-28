CREATE OR REPLACE FUNCTION get_communes_arrondissements_count(communes communes)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "communes" AS "arrondissements"
      WHERE  "arrondissements"."code_arrondissement" = communes."code_insee"
    );
  END;
$function$ LANGUAGE plpgsql;
