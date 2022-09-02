CREATE OR REPLACE FUNCTION get_services_communes_count(services services)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT      COUNT(*)
      FROM        "communes"
      INNER JOIN  "service_communes" ON "service_communes"."code_insee" = "communes"."code_insee"
      WHERE       "service_communes"."service_id" = services."id"
    );
  END;
$function$ LANGUAGE plpgsql;
