CREATE OR REPLACE FUNCTION get_offices_communes_count(offices offices)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT      COUNT(*)
      FROM        "communes"
      INNER JOIN  "office_communes" ON "office_communes"."code_insee" = "communes"."code_insee"
      WHERE       "office_communes"."office_id" = offices."id"
    );
  END;
$function$ LANGUAGE plpgsql;
