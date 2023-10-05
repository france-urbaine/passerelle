CREATE OR REPLACE FUNCTION get_ddfips_offices_count(ddfips ddfips)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "offices"
      WHERE  "offices"."ddfip_id" = ddfips."id"
        AND  "offices"."discarded_at" IS NULL
    );
  END;
$function$ LANGUAGE plpgsql;
