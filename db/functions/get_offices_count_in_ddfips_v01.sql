CREATE OR REPLACE FUNCTION get_offices_count_in_ddfips(ddfips ddfips)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "offices"
      WHERE  "offices"."ddfip_id" = ddfips."id"
    );
  END;
$function$ LANGUAGE plpgsql;
