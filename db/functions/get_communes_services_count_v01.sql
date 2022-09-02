CREATE OR REPLACE FUNCTION get_communes_services_count(communes communes)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT      COUNT(*)
      FROM        "services"
      INNER JOIN  "service_communes" ON "service_communes"."service_id" = "services"."id"
      WHERE       "service_communes"."code_insee" = communes."code_insee"
    );
  END;
$function$ LANGUAGE plpgsql;
