CREATE OR REPLACE FUNCTION get_collectivities_packages_assigned_count(collectivities collectivities)
RETURNS integer
AS $function$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "packages"
      WHERE  "packages"."sandbox" = FALSE
        AND  "packages"."discarded_at" IS NULL
        AND  "packages"."assigned_at"  IS NOT NULL
        AND  "packages"."returned_at"  IS NULL
        AND  "packages"."collectivity_id" = collectivities."id"
    );
  END;
$function$ LANGUAGE plpgsql;
