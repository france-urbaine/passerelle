CREATE OR REPLACE FUNCTION get_ddfips_services_count(ddfips ddfips)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "services"
      WHERE  "services"."ddfip_id" = ddfips."id"
    );
  END;
$function$ LANGUAGE plpgsql;
