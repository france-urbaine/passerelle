CREATE OR REPLACE FUNCTION get_communes_offices_count(communes communes)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT      COUNT(*)
      FROM        "offices"
      INNER JOIN  "office_communes" ON "office_communes"."office_id" = "offices"."id"
      WHERE       "office_communes"."code_insee" = communes."code_insee"
    );
  END;
$function$ LANGUAGE plpgsql;
