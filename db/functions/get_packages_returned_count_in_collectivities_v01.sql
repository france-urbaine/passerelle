CREATE OR REPLACE FUNCTION get_packages_returned_count_in_collectivities(collectivities collectivities)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "packages"
      WHERE  "packages"."collectivity_id" = collectivities."id"
        AND  "packages"."sandbox" = FALSE
        AND  "packages"."transmitted_at" IS NOT NULL
        AND  "packages"."returned_at" IS NOT NULL
        AND  "packages"."discarded_at" IS NULL
    );
  END;
$function$ LANGUAGE plpgsql;
