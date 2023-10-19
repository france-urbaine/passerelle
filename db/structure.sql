SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- Name: action; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.action AS ENUM (
    'evaluation_hab',
    'evaluation_pro',
    'occupation_hab',
    'occupation_pro'
);


--
-- Name: anomaly; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.anomaly AS ENUM (
    'consistance',
    'affectation',
    'exoneration',
    'adresse',
    'correctif',
    'omission_batie',
    'construction_neuve',
    'occupation',
    'categorie'
);


--
-- Name: epci_nature; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.epci_nature AS ENUM (
    'ME',
    'CC',
    'CA',
    'CU'
);


--
-- Name: exoneration_base; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.exoneration_base AS ENUM (
    'imposable',
    'impose'
);


--
-- Name: exoneration_code_collectivite; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.exoneration_code_collectivite AS ENUM (
    'C',
    'GC',
    'TS',
    'OM'
);


--
-- Name: exoneration_status; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.exoneration_status AS ENUM (
    'conserver',
    'supprimer',
    'ajouter'
);


--
-- Name: form_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.form_type AS ENUM (
    'evaluation_local_habitation',
    'evaluation_local_professionnel',
    'creation_local_habitation',
    'creation_local_professionnel',
    'occupation_local_habitation',
    'occupation_local_professionnel'
);


--
-- Name: organization_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.organization_type AS ENUM (
    'Collectivity',
    'Publisher',
    'DDFIP',
    'DGFIP'
);


--
-- Name: otp_method; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.otp_method AS ENUM (
    '2fa',
    'email'
);


--
-- Name: priority; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.priority AS ENUM (
    'low',
    'medium',
    'high'
);


--
-- Name: territory_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.territory_type AS ENUM (
    'Commune',
    'EPCI',
    'Departement',
    'Region'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: collectivities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collectivities (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    territory_type public.territory_type NOT NULL,
    territory_id uuid NOT NULL,
    publisher_id uuid,
    name character varying NOT NULL,
    siren character varying NOT NULL,
    contact_first_name character varying,
    contact_last_name character varying,
    contact_email character varying,
    contact_phone character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    approved_at timestamp(6) without time zone,
    disapproved_at timestamp(6) without time zone,
    desactivated_at timestamp(6) without time zone,
    discarded_at timestamp(6) without time zone,
    users_count integer DEFAULT 0 NOT NULL,
    domain_restriction character varying,
    allow_2fa_via_email boolean DEFAULT false NOT NULL,
    allow_publisher_management boolean DEFAULT false NOT NULL,
    reports_incomplete_count integer DEFAULT 0 NOT NULL,
    reports_packing_count integer DEFAULT 0 NOT NULL,
    reports_transmitted_count integer DEFAULT 0 NOT NULL,
    reports_returned_count integer DEFAULT 0 NOT NULL,
    reports_pending_count integer DEFAULT 0 NOT NULL,
    reports_debated_count integer DEFAULT 0 NOT NULL,
    reports_approved_count integer DEFAULT 0 NOT NULL,
    reports_rejected_count integer DEFAULT 0 NOT NULL,
    packages_transmitted_count integer DEFAULT 0 NOT NULL,
    packages_unresolved_count integer DEFAULT 0 NOT NULL,
    packages_assigned_count integer DEFAULT 0 NOT NULL,
    packages_returned_count integer DEFAULT 0 NOT NULL,
    CONSTRAINT users_count_check CHECK ((users_count >= 0))
);


--
-- Name: get_collectivities_packages_assigned_count(public.collectivities); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_collectivities_packages_assigned_count(collectivities public.collectivities) RETURNS integer
    LANGUAGE plpgsql
    AS $$
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
$$;


--
-- Name: get_collectivities_packages_returned_count(public.collectivities); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_collectivities_packages_returned_count(collectivities public.collectivities) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "packages"
      WHERE  "packages"."sandbox" = FALSE
        AND  "packages"."discarded_at" IS NULL
        AND  "packages"."returned_at"  IS NOT NULL
        AND  "packages"."collectivity_id" = collectivities."id"
    );
  END;
$$;


--
-- Name: get_collectivities_packages_transmitted_count(public.collectivities); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_collectivities_packages_transmitted_count(collectivities public.collectivities) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "packages"
      WHERE  "packages"."sandbox" = FALSE
        AND  "packages"."discarded_at" IS NULL
        AND  "packages"."collectivity_id" = collectivities."id"
    );
  END;
$$;


--
-- Name: get_collectivities_packages_unresolved_count(public.collectivities); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_collectivities_packages_unresolved_count(collectivities public.collectivities) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "packages"
      WHERE  "packages"."sandbox" = FALSE
        AND  "packages"."discarded_at" IS NULL
        AND  "packages"."assigned_at"  IS NULL
        AND  "packages"."returned_at"  IS NULL
        AND  "packages"."collectivity_id" = collectivities."id"
    );
  END;
$$;


--
-- Name: get_collectivities_reports_approved_count(public.collectivities); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_collectivities_reports_approved_count(collectivities public.collectivities) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
      WHERE      "packages"."sandbox" = FALSE
        AND      "packages"."discarded_at" IS NULL
        AND      "packages"."assigned_at"  IS NOT NULL
        AND      "packages"."returned_at"  IS NULL
        AND      "reports"."discarded_at"  IS NULL
        AND      "reports"."approved_at"   IS NOT NULL
        AND      "reports"."rejected_at"   IS NULL
        AND      "reports"."collectivity_id" = collectivities."id"
    );
  END;
$$;


--
-- Name: get_collectivities_reports_debated_count(public.collectivities); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_collectivities_reports_debated_count(collectivities public.collectivities) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
      WHERE      "packages"."sandbox" = FALSE
        AND      "packages"."discarded_at" IS NULL
        AND      "packages"."assigned_at"  IS NOT NULL
        AND      "packages"."returned_at"  IS NULL
        AND      "reports"."discarded_at"  IS NULL
        AND      "reports"."debated_at"    IS NOT NULL
        AND      "reports"."approved_at"   IS NULL
        AND      "reports"."rejected_at"   IS NULL
        AND      "reports"."collectivity_id" = collectivities."id"
    );
  END;
$$;


--
-- Name: get_collectivities_reports_incomplete_count(public.collectivities); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_collectivities_reports_incomplete_count(collectivities public.collectivities) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      WHERE      "reports"."discarded_at" IS NULL
        AND      "reports"."package_id"   IS NULL
        AND      "reports"."completed_at" IS NULL
        AND      "reports"."publisher_id" IS NULL
        AND      "reports"."collectivity_id" = collectivities."id"
    );
  END;
$$;


--
-- Name: get_collectivities_reports_packing_count(public.collectivities); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_collectivities_reports_packing_count(collectivities public.collectivities) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      WHERE      "reports"."discarded_at" IS NULL
        AND      "reports"."package_id"   IS NULL
        AND      "reports"."publisher_id" IS NULL
        AND      "reports"."collectivity_id" = collectivities."id"
    );
  END;
$$;


--
-- Name: get_collectivities_reports_pending_count(public.collectivities); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_collectivities_reports_pending_count(collectivities public.collectivities) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
      WHERE      "packages"."sandbox" = FALSE
        AND      "packages"."discarded_at" IS NULL
        AND      "packages"."assigned_at"  IS NOT NULL
        AND      "packages"."returned_at"  IS NULL
        AND      "reports"."discarded_at"  IS NULL
        AND      "reports"."debated_at"    IS NULL
        AND      "reports"."approved_at"   IS NULL
        AND      "reports"."rejected_at"   IS NULL
        AND      "reports"."collectivity_id" = collectivities."id"
    );
  END;
$$;


--
-- Name: get_collectivities_reports_rejected_count(public.collectivities); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_collectivities_reports_rejected_count(collectivities public.collectivities) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
      WHERE      "packages"."sandbox" = FALSE
        AND      "packages"."discarded_at" IS NULL
        AND      "packages"."assigned_at"  IS NOT NULL
        AND      "packages"."returned_at"  IS NULL
        AND      "reports"."discarded_at"  IS NULL
        AND      "reports"."rejected_at"   IS NOT NULL
        AND      "reports"."collectivity_id" = collectivities."id"
    );
  END;
$$;


--
-- Name: get_collectivities_reports_returned_count(public.collectivities); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_collectivities_reports_returned_count(collectivities public.collectivities) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
      WHERE      "packages"."sandbox" = FALSE
        AND      "packages"."discarded_at" IS NULL
        AND      "packages"."returned_at"  IS NOT NULL
        AND      "reports"."discarded_at"  IS NULL
        AND      "reports"."collectivity_id" = collectivities."id"
    );
  END;
$$;


--
-- Name: get_collectivities_reports_transmitted_count(public.collectivities); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_collectivities_reports_transmitted_count(collectivities public.collectivities) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
      WHERE      "packages"."sandbox" = FALSE
        AND      "packages"."discarded_at" IS NULL
        AND      "reports"."discarded_at"  IS NULL
        AND      "reports"."collectivity_id" = collectivities."id"
    );
  END;
$$;


--
-- Name: get_collectivities_users_count(public.collectivities); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_collectivities_users_count(collectivities public.collectivities) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "users"
      WHERE  "users"."organization_type" = 'Collectivity'
        AND  "users"."organization_id"   = collectivities."id"
        AND  "users"."discarded_at" IS NULL
    );
  END;
$$;


--
-- Name: communes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.communes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    code_insee character varying NOT NULL,
    code_departement character varying NOT NULL,
    siren_epci character varying,
    qualified_name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    collectivities_count integer DEFAULT 0 NOT NULL,
    offices_count integer DEFAULT 0 NOT NULL,
    CONSTRAINT collectivities_count_check CHECK ((collectivities_count >= 0)),
    CONSTRAINT offices_count_check CHECK ((offices_count >= 0))
);


--
-- Name: get_communes_collectivities_count(public.communes); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_communes_collectivities_count(communes public.communes) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "collectivities"
      WHERE  "collectivities"."discarded_at" IS NULL AND (
        (
          "collectivities"."territory_type" = 'Commune' AND
          "collectivities"."territory_id"   = communes."id"
        ) OR (
          "collectivities"."territory_type" = 'EPCI' AND
          "collectivities"."territory_id" IN (
            SELECT "epcis"."id"
            FROM   "epcis"
            WHERE  "epcis"."siren" = communes."siren_epci"
          )
        ) OR (
          "collectivities"."territory_type" = 'Departement' AND
          "collectivities"."territory_id" IN (
            SELECT "departements"."id"
            FROM   "departements"
            WHERE  "departements"."code_departement" = communes."code_departement"
          )
        ) OR (
          "collectivities"."territory_type" = 'Region' AND
          "collectivities"."territory_id" IN (
            SELECT     "regions"."id"
            FROM       "regions"
            INNER JOIN "departements" ON "departements"."code_region" = "regions"."code_region"
            WHERE      "departements"."code_departement" = communes."code_departement"
          )
        )
      )
    );
  END;
$$;


--
-- Name: get_communes_offices_count(public.communes); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_communes_offices_count(communes public.communes) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT      COUNT(*)
      FROM        "offices"
      INNER JOIN  "office_communes" ON "office_communes"."office_id" = "offices"."id"
      WHERE       "office_communes"."code_insee" = communes."code_insee"
    );
  END;
$$;


--
-- Name: ddfips; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ddfips (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    code_departement character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    discarded_at timestamp(6) without time zone,
    users_count integer DEFAULT 0 NOT NULL,
    collectivities_count integer DEFAULT 0 NOT NULL,
    offices_count integer DEFAULT 0 NOT NULL,
    contact_first_name character varying,
    contact_last_name character varying,
    contact_email character varying,
    contact_phone character varying,
    domain_restriction character varying,
    allow_2fa_via_email boolean DEFAULT false NOT NULL,
    auto_assign_packages boolean DEFAULT false NOT NULL,
    reports_transmitted_count integer DEFAULT 0 NOT NULL,
    reports_returned_count integer DEFAULT 0 NOT NULL,
    reports_pending_count integer DEFAULT 0 NOT NULL,
    reports_debated_count integer DEFAULT 0 NOT NULL,
    reports_approved_count integer DEFAULT 0 NOT NULL,
    reports_rejected_count integer DEFAULT 0 NOT NULL,
    packages_transmitted_count integer DEFAULT 0 NOT NULL,
    packages_unresolved_count integer DEFAULT 0 NOT NULL,
    packages_assigned_count integer DEFAULT 0 NOT NULL,
    packages_returned_count integer DEFAULT 0 NOT NULL,
    CONSTRAINT collectivities_count_check CHECK ((collectivities_count >= 0)),
    CONSTRAINT offices_count_check CHECK ((offices_count >= 0)),
    CONSTRAINT users_count_check CHECK ((users_count >= 0))
);


--
-- Name: get_ddfips_collectivities_count(public.ddfips); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_ddfips_collectivities_count(ddfips public.ddfips) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "collectivities"
      WHERE  "collectivities"."discarded_at" IS NULL AND (
        (
          "collectivities"."territory_type" = 'Commune' AND
          "collectivities"."territory_id" IN (
            SELECT "communes"."id"
            FROM   "communes"
            WHERE  "communes"."code_departement" = ddfips."code_departement"
          )
        ) OR (
          "collectivities"."territory_type" = 'EPCI' AND
          "collectivities"."territory_id" IN (
            SELECT     "epcis"."id"
            FROM       "epcis"
            INNER JOIN "communes" ON "communes"."siren_epci" = "epcis"."siren"
            WHERE      "communes"."code_departement" = ddfips."code_departement"
          )
        ) OR (
          "collectivities"."territory_type" = 'Departement' AND
          "collectivities"."territory_id" IN (
            SELECT "departements"."id"
            FROM   "departements"
            WHERE  "departements"."code_departement" = ddfips."code_departement"
          )
        ) OR (
          "collectivities"."territory_type" = 'Region' AND
          "collectivities"."territory_id" IN (
            SELECT     "regions"."id"
            FROM       "regions"
            INNER JOIN "departements" ON "departements"."code_region" = "regions"."code_region"
            WHERE      "departements"."code_departement" = ddfips."code_departement"
          )
        )
      )
    );
  END;
$$;


--
-- Name: get_ddfips_offices_count(public.ddfips); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_ddfips_offices_count(ddfips public.ddfips) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "offices"
      WHERE  "offices"."ddfip_id" = ddfips."id"
        AND  "offices"."discarded_at" IS NULL
    );
  END;
$$;


--
-- Name: get_ddfips_packages_assigned_count(public.ddfips); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_ddfips_packages_assigned_count(ddfips public.ddfips) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "packages"
      WHERE  "packages"."sandbox" = FALSE
        AND  "packages"."discarded_at" IS NULL
        AND  "packages"."assigned_at"  IS NOT NULL
        AND  "packages"."returned_at"  IS NULL
        AND  "packages"."id" IN (
                SELECT     "reports"."package_id"
                FROM       "reports"
                INNER JOIN "communes" ON "communes"."code_insee" = "reports"."code_insee"
                WHERE      "communes"."code_departement" = ddfips."code_departement"
             )
    );
  END;
$$;


--
-- Name: get_ddfips_packages_returned_count(public.ddfips); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_ddfips_packages_returned_count(ddfips public.ddfips) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "packages"
      WHERE  "packages"."sandbox" = FALSE
        AND  "packages"."discarded_at" IS NULL
        AND  "packages"."returned_at"  IS NOT NULL
        AND  "packages"."id" IN (
                SELECT     "reports"."package_id"
                FROM       "reports"
                INNER JOIN "communes" ON "communes"."code_insee" = "reports"."code_insee"
                WHERE      "communes"."code_departement" = ddfips."code_departement"
             )
    );
  END;
$$;


--
-- Name: get_ddfips_packages_transmitted_count(public.ddfips); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_ddfips_packages_transmitted_count(ddfips public.ddfips) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "packages"
      WHERE  "packages"."sandbox" = FALSE
        AND  "packages"."discarded_at" IS NULL
        AND  "packages"."id" IN (
                SELECT     "reports"."package_id"
                FROM       "reports"
                INNER JOIN "communes" ON "communes"."code_insee" = "reports"."code_insee"
                WHERE      "communes"."code_departement" = ddfips."code_departement"
             )
    );
  END;
$$;


--
-- Name: get_ddfips_packages_unresolved_count(public.ddfips); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_ddfips_packages_unresolved_count(ddfips public.ddfips) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "packages"
      WHERE  "packages"."sandbox" = FALSE
        AND  "packages"."discarded_at" IS NULL
        AND  "packages"."assigned_at"  IS NULL
        AND  "packages"."returned_at"  IS NULL
        AND  "packages"."id" IN (
                SELECT     "reports"."package_id"
                FROM       "reports"
                INNER JOIN "communes" ON "communes"."code_insee" = "reports"."code_insee"
                WHERE      "communes"."code_departement" = ddfips."code_departement"
             )
    );
  END;
$$;


--
-- Name: get_ddfips_reports_approved_count(public.ddfips); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_ddfips_reports_approved_count(ddfips public.ddfips) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
      INNER JOIN "communes" ON "communes"."code_insee" = "reports"."code_insee"
      WHERE      "communes"."code_departement" = ddfips."code_departement"
        AND      "packages"."sandbox" = FALSE
        AND      "packages"."discarded_at" IS NULL
        AND      "packages"."assigned_at"  IS NOT NULL
        AND      "packages"."returned_at"  IS NULL
        AND      "reports"."discarded_at"  IS NULL
        AND      "reports"."approved_at"   IS NOT NULL
        AND      "reports"."rejected_at"   IS NULL
    );
  END;
$$;


--
-- Name: get_ddfips_reports_debated_count(public.ddfips); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_ddfips_reports_debated_count(ddfips public.ddfips) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
      INNER JOIN "communes" ON "communes"."code_insee" = "reports"."code_insee"
      WHERE      "communes"."code_departement" = ddfips."code_departement"
        AND      "packages"."sandbox" = FALSE
        AND      "packages"."discarded_at" IS NULL
        AND      "packages"."assigned_at"  IS NOT NULL
        AND      "packages"."returned_at"  IS NULL
        AND      "reports"."discarded_at"  IS NULL
        AND      "reports"."debated_at"    IS NOT NULL
        AND      "reports"."approved_at"   IS NULL
        AND      "reports"."rejected_at"   IS NULL
    );
  END;
$$;


--
-- Name: get_ddfips_reports_pending_count(public.ddfips); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_ddfips_reports_pending_count(ddfips public.ddfips) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
      INNER JOIN "communes" ON "communes"."code_insee" = "reports"."code_insee"
      WHERE      "communes"."code_departement" = ddfips."code_departement"
        AND      "packages"."sandbox" = FALSE
        AND      "packages"."discarded_at" IS NULL
        AND      "packages"."assigned_at"  IS NOT NULL
        AND      "packages"."returned_at"  IS NULL
        AND      "reports"."discarded_at"  IS NULL
        AND      "reports"."debated_at"    IS NULL
        AND      "reports"."approved_at"   IS NULL
        AND      "reports"."rejected_at"   IS NULL
    );
  END;
$$;


--
-- Name: get_ddfips_reports_rejected_count(public.ddfips); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_ddfips_reports_rejected_count(ddfips public.ddfips) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
      INNER JOIN "communes" ON "communes"."code_insee" = "reports"."code_insee"
      WHERE      "communes"."code_departement" = ddfips."code_departement"
        AND      "packages"."sandbox" = FALSE
        AND      "packages"."discarded_at" IS NULL
        AND      "packages"."assigned_at"  IS NOT NULL
        AND      "packages"."returned_at"  IS NULL
        AND      "reports"."discarded_at"  IS NULL
        AND      "reports"."rejected_at"   IS NOT NULL
    );
  END;
$$;


--
-- Name: get_ddfips_reports_returned_count(public.ddfips); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_ddfips_reports_returned_count(ddfips public.ddfips) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
      INNER JOIN "communes" ON "communes"."code_insee" = "reports"."code_insee"
      WHERE      "communes"."code_departement" = ddfips."code_departement"
        AND      "packages"."sandbox" = FALSE
        AND      "packages"."discarded_at" IS NULL
        AND      "packages"."returned_at"  IS NOT NULL
        AND      "reports"."discarded_at"  IS NULL
    );
  END;
$$;


--
-- Name: get_ddfips_reports_transmitted_count(public.ddfips); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_ddfips_reports_transmitted_count(ddfips public.ddfips) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
      INNER JOIN "communes" ON "communes"."code_insee" = "reports"."code_insee"
      WHERE      "communes"."code_departement" = ddfips."code_departement"
        AND      "packages"."sandbox" = FALSE
        AND      "packages"."discarded_at" IS NULL
        AND      "reports"."discarded_at"  IS NULL
    );
  END;
$$;


--
-- Name: get_ddfips_users_count(public.ddfips); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_ddfips_users_count(ddfips public.ddfips) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "users"
      WHERE  "users"."organization_type" = 'DDFIP'
        AND  "users"."organization_id"   = ddfips."id"
        AND  "users"."discarded_at" IS NULL
    );
  END;
$$;


--
-- Name: departements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.departements (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    code_departement character varying NOT NULL,
    code_region character varying NOT NULL,
    qualified_name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    epcis_count integer DEFAULT 0 NOT NULL,
    communes_count integer DEFAULT 0 NOT NULL,
    ddfips_count integer DEFAULT 0 NOT NULL,
    collectivities_count integer DEFAULT 0 NOT NULL,
    CONSTRAINT collectivities_count_check CHECK ((collectivities_count >= 0)),
    CONSTRAINT communes_count_check CHECK ((communes_count >= 0)),
    CONSTRAINT ddfips_count_check CHECK ((ddfips_count >= 0)),
    CONSTRAINT epcis_count_check CHECK ((epcis_count >= 0))
);


--
-- Name: get_departements_collectivities_count(public.departements); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_departements_collectivities_count(departements public.departements) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "collectivities"
      WHERE  "collectivities"."discarded_at" IS NULL AND (
        (
          "collectivities"."territory_type" = 'Departement' AND
          "collectivities"."territory_id"   = departements."id"
        ) OR (
          "collectivities"."territory_type" = 'Commune' AND
          "collectivities"."territory_id" IN (
            SELECT "communes"."id"
            FROM   "communes"
            WHERE  "communes"."code_departement" = departements."code_departement"
          )
        ) OR (
          "collectivities"."territory_type" = 'EPCI' AND
          "collectivities"."territory_id" IN (
            SELECT     "epcis"."id"
            FROM       "epcis"
            INNER JOIN "communes" ON "communes"."siren_epci" = "epcis"."siren"
            WHERE      "communes"."code_departement" = departements."code_departement"
          )
        ) OR (
          "collectivities"."territory_type" = 'Region' AND
          "collectivities"."territory_id" IN (
            SELECT     "regions"."id"
            FROM       "regions"
            WHERE      "regions"."code_region" = departements."code_region"
          )
        )
      )
    );
  END;
$$;


--
-- Name: get_departements_communes_count(public.departements); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_departements_communes_count(departements public.departements) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "communes"
      WHERE  "communes"."code_departement" = departements."code_departement"
    );
  END;
$$;


--
-- Name: get_departements_ddfips_count(public.departements); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_departements_ddfips_count(departements public.departements) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "ddfips"
      WHERE  "ddfips"."code_departement" = departements."code_departement"
    );
  END;
$$;


--
-- Name: get_departements_epcis_count(public.departements); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_departements_epcis_count(departements public.departements) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "epcis"
      WHERE  "epcis"."code_departement" = departements."code_departement"
    );
  END;
$$;


--
-- Name: dgfips; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dgfips (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    contact_first_name character varying,
    contact_last_name character varying,
    contact_email character varying,
    contact_phone character varying,
    domain_restriction character varying,
    allow_2fa_via_email boolean DEFAULT false NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    discarded_at timestamp(6) without time zone,
    users_count integer DEFAULT 0 NOT NULL,
    reports_transmitted_count integer DEFAULT 0 NOT NULL,
    reports_returned_count integer DEFAULT 0 NOT NULL,
    reports_pending_count integer DEFAULT 0 NOT NULL,
    reports_debated_count integer DEFAULT 0 NOT NULL,
    reports_approved_count integer DEFAULT 0 NOT NULL,
    reports_rejected_count integer DEFAULT 0 NOT NULL,
    packages_transmitted_count integer DEFAULT 0 NOT NULL,
    packages_assigned_count integer DEFAULT 0 NOT NULL,
    packages_returned_count integer DEFAULT 0 NOT NULL,
    CONSTRAINT users_count_check CHECK ((users_count >= 0))
);


--
-- Name: get_dgfips_packages_assigned_count(public.dgfips); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_dgfips_packages_assigned_count(dgfips public.dgfips) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "packages"
      WHERE  "packages"."sandbox" = FALSE
        AND  "packages"."discarded_at" IS NULL
        AND  "packages"."assigned_at"  IS NOT NULL
        AND  "packages"."returned_at"  IS NULL
    );
  END;
$$;


--
-- Name: get_dgfips_packages_returned_count(public.dgfips); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_dgfips_packages_returned_count(dgfips public.dgfips) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "packages"
      WHERE  "packages"."sandbox" = FALSE
        AND  "packages"."discarded_at" IS NULL
        AND  "packages"."returned_at"  IS NOT NULL
    );
  END;
$$;


--
-- Name: get_dgfips_packages_transmitted_count(public.dgfips); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_dgfips_packages_transmitted_count(dgfips public.dgfips) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "packages"
      WHERE  "packages"."sandbox" = FALSE
        AND  "packages"."discarded_at" IS NULL
    );
  END;
$$;


--
-- Name: get_dgfips_reports_approved_count(public.dgfips); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_dgfips_reports_approved_count(dgfips public.dgfips) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
      WHERE      "packages"."sandbox" = FALSE
        AND      "packages"."discarded_at" IS NULL
        AND      "packages"."assigned_at"  IS NOT NULL
        AND      "packages"."returned_at"  IS NULL
        AND      "reports"."discarded_at"  IS NULL
        AND      "reports"."approved_at"   IS NOT NULL
        AND      "reports"."rejected_at"   IS NULL
    );
  END;
$$;


--
-- Name: get_dgfips_reports_debated_count(public.dgfips); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_dgfips_reports_debated_count(dgfips public.dgfips) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
      WHERE      "packages"."sandbox" = FALSE
        AND      "packages"."discarded_at" IS NULL
        AND      "packages"."assigned_at"  IS NOT NULL
        AND      "packages"."returned_at"  IS NULL
        AND      "reports"."discarded_at"  IS NULL
        AND      "reports"."debated_at"    IS NOT NULL
        AND      "reports"."approved_at"   IS NULL
        AND      "reports"."rejected_at"   IS NULL
    );
  END;
$$;


--
-- Name: get_dgfips_reports_pending_count(public.dgfips); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_dgfips_reports_pending_count(dgfips public.dgfips) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
      WHERE      "packages"."sandbox" = FALSE
        AND      "packages"."discarded_at" IS NULL
        AND      "packages"."assigned_at"  IS NOT NULL
        AND      "packages"."returned_at"  IS NULL
        AND      "reports"."discarded_at"  IS NULL
        AND      "reports"."debated_at"    IS NULL
        AND      "reports"."approved_at"   IS NULL
        AND      "reports"."rejected_at"   IS NULL
    );
  END;
$$;


--
-- Name: get_dgfips_reports_rejected_count(public.dgfips); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_dgfips_reports_rejected_count(dgfips public.dgfips) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
      WHERE      "packages"."sandbox" = FALSE
        AND      "packages"."discarded_at" IS NULL
        AND      "packages"."assigned_at"  IS NOT NULL
        AND      "packages"."returned_at"  IS NULL
        AND      "reports"."discarded_at"  IS NULL
        AND      "reports"."rejected_at"   IS NOT NULL
    );
  END;
$$;


--
-- Name: get_dgfips_reports_returned_count(public.dgfips); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_dgfips_reports_returned_count(dgfips public.dgfips) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
      WHERE      "packages"."sandbox" = FALSE
        AND      "packages"."discarded_at" IS NULL
        AND      "packages"."returned_at"  IS NOT NULL
        AND      "reports"."discarded_at"  IS NULL
    );
  END;
$$;


--
-- Name: get_dgfips_reports_transmitted_count(public.dgfips); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_dgfips_reports_transmitted_count(dgfips public.dgfips) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
      WHERE      "packages"."sandbox" = FALSE
        AND      "packages"."discarded_at" IS NULL
        AND      "reports"."discarded_at"  IS NULL
    );
  END;
$$;


--
-- Name: get_dgfips_users_count(public.dgfips); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_dgfips_users_count(dgfips public.dgfips) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "users"
      WHERE  "users"."organization_type" = 'DGFIP'
        AND  "users"."organization_id"   = dgfips."id"
        AND  "users"."discarded_at" IS NULL
    );
  END;
$$;


--
-- Name: epcis; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.epcis (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    siren character varying NOT NULL,
    code_departement character varying,
    nature public.epci_nature,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    communes_count integer DEFAULT 0 NOT NULL,
    collectivities_count integer DEFAULT 0 NOT NULL,
    CONSTRAINT collectivities_count_check CHECK ((collectivities_count >= 0)),
    CONSTRAINT communes_count_check CHECK ((communes_count >= 0))
);


--
-- Name: get_epcis_collectivities_count(public.epcis); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_epcis_collectivities_count(epcis public.epcis) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "collectivities"
      WHERE  "collectivities"."discarded_at" IS NULL AND (
        (
          "collectivities"."territory_type" = 'EPCI' AND
          "collectivities"."territory_id"   = epcis."id"
        ) OR (
          "collectivities"."territory_type" = 'Commune' AND
          "collectivities"."territory_id" IN (
            SELECT "communes"."id"
            FROM   "communes"
            WHERE  "communes"."siren_epci" = epcis."siren"
          )
        ) OR (
          "collectivities"."territory_type" = 'Departement' AND
          "collectivities"."territory_id" IN (
            SELECT     "departements"."id"
            FROM       "departements"
            INNER JOIN "communes" ON "communes"."code_departement" = "departements"."code_departement"
            WHERE      "communes"."siren_epci" = epcis."siren"
          )
        ) OR (
          "collectivities"."territory_type" = 'Region' AND
          "collectivities"."territory_id" IN (
            SELECT     "regions"."id"
            FROM       "regions"
            INNER JOIN "departements" ON "departements"."code_region" = "regions"."code_region"
            INNER JOIN "communes"     ON "communes"."code_departement" = "departements"."code_departement"
            WHERE      "communes"."siren_epci" = epcis."siren"
          )
        )
      )
    );
  END;
$$;


--
-- Name: get_epcis_communes_count(public.epcis); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_epcis_communes_count(epcis public.epcis) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "communes"
      WHERE  "communes"."siren_epci" = epcis."siren"
    );
  END;
$$;


--
-- Name: offices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.offices (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ddfip_id uuid NOT NULL,
    name character varying NOT NULL,
    competences public.form_type[] NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    discarded_at timestamp(6) without time zone,
    users_count integer DEFAULT 0 NOT NULL,
    communes_count integer DEFAULT 0 NOT NULL,
    reports_assigned_count integer DEFAULT 0 NOT NULL,
    reports_pending_count integer DEFAULT 0 NOT NULL,
    reports_debated_count integer DEFAULT 0 NOT NULL,
    reports_approved_count integer DEFAULT 0 NOT NULL,
    reports_rejected_count integer DEFAULT 0 NOT NULL
);


--
-- Name: get_offices_communes_count(public.offices); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_offices_communes_count(offices public.offices) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT      COUNT(*)
      FROM        "communes"
      INNER JOIN  "office_communes" ON "office_communes"."code_insee" = "communes"."code_insee"
      WHERE       "office_communes"."office_id" = offices."id"
    );
  END;
$$;


--
-- Name: get_offices_reports_approved_count(public.offices); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_offices_reports_approved_count(offices public.offices) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
      INNER JOIN "office_communes"
         ON      "office_communes"."code_insee" = "reports"."code_insee"
        AND      "office_communes"."office_id" = offices."id"
      WHERE      ARRAY["reports"."form_type"] <@ offices."competences"
        AND      "packages"."sandbox" = FALSE
        AND      "packages"."discarded_at" IS NULL
        AND      "packages"."assigned_at"  IS NOT NULL
        AND      "packages"."returned_at"  IS NULL
        AND      "reports"."discarded_at"  IS NULL
        AND      "reports"."approved_at"   IS NOT NULL
        AND      "reports"."rejected_at"   IS NULL
    );
  END;
$$;


--
-- Name: get_offices_reports_assigned_count(public.offices); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_offices_reports_assigned_count(offices public.offices) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
      INNER JOIN "office_communes"
         ON      "office_communes"."code_insee" = "reports"."code_insee"
        AND      "office_communes"."office_id" = offices."id"
      WHERE      ARRAY["reports"."form_type"] <@ offices."competences"
        AND      "packages"."sandbox" = FALSE
        AND      "packages"."discarded_at" IS NULL
        AND      "packages"."assigned_at"  IS NOT NULL
        AND      "packages"."returned_at"  IS NULL
        AND      "reports"."discarded_at"  IS NULL
    );
  END;
$$;


--
-- Name: get_offices_reports_debated_count(public.offices); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_offices_reports_debated_count(offices public.offices) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
      INNER JOIN "office_communes"
         ON      "office_communes"."code_insee" = "reports"."code_insee"
        AND      "office_communes"."office_id" = offices."id"
      WHERE      ARRAY["reports"."form_type"] <@ offices."competences"
        AND      "packages"."sandbox" = FALSE
        AND      "packages"."discarded_at" IS NULL
        AND      "packages"."assigned_at"  IS NOT NULL
        AND      "packages"."returned_at"  IS NULL
        AND      "reports"."discarded_at"  IS NULL
        AND      "reports"."debated_at"    IS NOT NULL
        AND      "reports"."approved_at"   IS NULL
        AND      "reports"."rejected_at"   IS NULL
    );
  END;
$$;


--
-- Name: get_offices_reports_pending_count(public.offices); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_offices_reports_pending_count(offices public.offices) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
      INNER JOIN "office_communes"
         ON      "office_communes"."code_insee" = "reports"."code_insee"
        AND      "office_communes"."office_id" = offices."id"
      WHERE      ARRAY["reports"."form_type"] <@ offices."competences"
        AND      "packages"."sandbox" = FALSE
        AND      "packages"."discarded_at" IS NULL
        AND      "packages"."assigned_at"  IS NOT NULL
        AND      "packages"."returned_at"  IS NULL
        AND      "reports"."discarded_at"  IS NULL
        AND      "reports"."debated_at"    IS NULL
        AND      "reports"."approved_at"   IS NULL
        AND      "reports"."rejected_at"   IS NULL
    );
  END;
$$;


--
-- Name: get_offices_reports_rejected_count(public.offices); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_offices_reports_rejected_count(offices public.offices) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
      INNER JOIN "office_communes"
         ON      "office_communes"."code_insee" = "reports"."code_insee"
        AND      "office_communes"."office_id" = offices."id"
      WHERE      ARRAY["reports"."form_type"] <@ offices."competences"
        AND      "packages"."sandbox" = FALSE
        AND      "packages"."discarded_at" IS NULL
        AND      "packages"."assigned_at"  IS NOT NULL
        AND      "packages"."returned_at"  IS NULL
        AND      "reports"."discarded_at"  IS NULL
        AND      "reports"."rejected_at"   IS NOT NULL
    );
  END;
$$;


--
-- Name: get_offices_users_count(public.offices); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_offices_users_count(offices public.offices) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT      COUNT(*)
      FROM        "users"
      INNER JOIN  "office_users" ON "office_users"."user_id" = "users"."id"
      WHERE       "office_users"."office_id" = offices."id"
        AND       "users"."discarded_at" IS NULL
    );
  END;
$$;


--
-- Name: packages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.packages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    collectivity_id uuid NOT NULL,
    publisher_id uuid,
    name character varying,
    reference character varying NOT NULL,
    form_type public.form_type NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    transmitted_at timestamp(6) without time zone NOT NULL,
    assigned_at timestamp(6) without time zone,
    returned_at timestamp(6) without time zone,
    discarded_at timestamp(6) without time zone,
    due_on date,
    reports_count integer DEFAULT 0 NOT NULL,
    reports_approved_count integer DEFAULT 0 NOT NULL,
    reports_rejected_count integer DEFAULT 0 NOT NULL,
    reports_debated_count integer DEFAULT 0 NOT NULL,
    sandbox boolean DEFAULT false NOT NULL,
    transmission_id uuid
);


--
-- Name: get_packages_reports_approved_count(public.packages); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_packages_reports_approved_count(packages public.packages) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "reports"
      WHERE  "reports"."discarded_at" IS NULL
        AND  "reports"."approved_at"  IS NOT NULL
        AND  "reports"."rejected_at"  IS NULL
        AND  "reports"."package_id" = packages."id"
    );
  END;
$$;


--
-- Name: get_packages_reports_count(public.packages); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_packages_reports_count(packages public.packages) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "reports"
      WHERE  "reports"."discarded_at" IS NULL
        AND  "reports"."package_id" = packages."id"
    );
  END;
$$;


--
-- Name: get_packages_reports_debated_count(public.packages); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_packages_reports_debated_count(packages public.packages) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "reports"
      WHERE  "reports"."discarded_at" IS NULL
        AND  "reports"."debated_at"   IS NOT NULL
        AND  "reports"."approved_at"  IS NULL
        AND  "reports"."rejected_at"  IS NULL
        AND  "reports"."package_id" = packages."id"
    );
  END;
$$;


--
-- Name: get_packages_reports_rejected_count(public.packages); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_packages_reports_rejected_count(packages public.packages) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "reports"
      WHERE  "reports"."discarded_at" IS NULL
        AND  "reports"."rejected_at"  IS NOT NULL
        AND  "reports"."package_id" = packages."id"
    );
  END;
$$;


--
-- Name: publishers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.publishers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    siren character varying NOT NULL,
    contact_email character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    discarded_at timestamp(6) without time zone,
    users_count integer DEFAULT 0 NOT NULL,
    collectivities_count integer DEFAULT 0 NOT NULL,
    contact_first_name character varying,
    contact_last_name character varying,
    contact_phone character varying,
    domain_restriction character varying,
    allow_2fa_via_email boolean DEFAULT false NOT NULL,
    reports_transmitted_count integer DEFAULT 0 NOT NULL,
    reports_approved_count integer DEFAULT 0 NOT NULL,
    reports_rejected_count integer DEFAULT 0 NOT NULL,
    reports_debated_count integer DEFAULT 0 NOT NULL,
    packages_transmitted_count integer DEFAULT 0 NOT NULL,
    packages_assigned_count integer DEFAULT 0 NOT NULL,
    packages_returned_count integer DEFAULT 0 NOT NULL,
    sandbox boolean DEFAULT false NOT NULL,
    CONSTRAINT collectivities_count_check CHECK ((collectivities_count >= 0)),
    CONSTRAINT users_count_check CHECK ((users_count >= 0))
);


--
-- Name: get_publishers_collectivities_count(public.publishers); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_publishers_collectivities_count(publishers public.publishers) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "collectivities"
      WHERE  "collectivities"."discarded_at" IS NULL
        AND  "collectivities"."publisher_id" = publishers."id"
    );
  END;
$$;


--
-- Name: get_publishers_packages_assigned_count(public.publishers); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_publishers_packages_assigned_count(publishers public.publishers) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "packages"
      WHERE  "packages"."sandbox" = FALSE
        AND  "packages"."discarded_at" IS NULL
        AND  "packages"."assigned_at"  IS NOT NULL
        AND  "packages"."returned_at"  IS NULL
        AND  "packages"."publisher_id" = publishers."id"
    );
  END;
$$;


--
-- Name: get_publishers_packages_returned_count(public.publishers); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_publishers_packages_returned_count(publishers public.publishers) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "packages"
      WHERE  "packages"."sandbox" = FALSE
        AND  "packages"."discarded_at" IS NULL
        AND  "packages"."returned_at"  IS NOT NULL
        AND  "packages"."publisher_id" = publishers."id"
    );
  END;
$$;


--
-- Name: get_publishers_packages_transmitted_count(public.publishers); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_publishers_packages_transmitted_count(publishers public.publishers) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "packages"
      WHERE  "packages"."sandbox" = FALSE
        AND  "packages"."discarded_at" IS NULL
        AND  "packages"."publisher_id" = publishers."id"
    );
  END;
$$;


--
-- Name: get_publishers_reports_approved_count(public.publishers); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_publishers_reports_approved_count(publishers public.publishers) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
      WHERE      "packages"."sandbox" = FALSE
        AND      "packages"."discarded_at" IS NULL
        AND      "packages"."assigned_at"  IS NOT NULL
        AND      "packages"."returned_at"  IS NULL
        AND      "reports"."discarded_at"  IS NULL
        AND      "reports"."approved_at"   IS NOT NULL
        AND      "reports"."rejected_at"   IS NULL
        AND      "reports"."publisher_id" = publishers."id"
    );
  END;
$$;


--
-- Name: get_publishers_reports_debated_count(public.publishers); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_publishers_reports_debated_count(publishers public.publishers) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
      WHERE      "packages"."sandbox" = FALSE
        AND      "packages"."discarded_at" IS NULL
        AND      "packages"."assigned_at"  IS NOT NULL
        AND      "packages"."returned_at"  IS NULL
        AND      "reports"."discarded_at"  IS NULL
        AND      "reports"."debated_at"    IS NOT NULL
        AND      "reports"."approved_at"   IS NULL
        AND      "reports"."rejected_at"   IS NULL
        AND      "reports"."publisher_id" = publishers."id"
    );
  END;
$$;


--
-- Name: get_publishers_reports_rejected_count(public.publishers); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_publishers_reports_rejected_count(publishers public.publishers) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
      WHERE      "packages"."sandbox" = FALSE
        AND      "packages"."discarded_at" IS NULL
        AND      "packages"."assigned_at"  IS NOT NULL
        AND      "packages"."returned_at"  IS NULL
        AND      "reports"."discarded_at"  IS NULL
        AND      "reports"."rejected_at"   IS NOT NULL
        AND      "reports"."publisher_id" = publishers."id"
    );
  END;
$$;


--
-- Name: get_publishers_reports_transmitted_count(public.publishers); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_publishers_reports_transmitted_count(publishers public.publishers) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "reports"
      INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
      WHERE      "packages"."sandbox" = FALSE
        AND      "packages"."discarded_at" IS NULL
        AND      "reports"."discarded_at"  IS NULL
        AND      "reports"."publisher_id" = publishers."id"
    );
  END;
$$;


--
-- Name: get_publishers_users_count(public.publishers); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_publishers_users_count(publishers public.publishers) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "users"
      WHERE  "users"."organization_type" = 'Publisher'
        AND  "users"."organization_id"   = publishers."id"
        AND  "users"."discarded_at" IS NULL
    );
  END;
$$;


--
-- Name: regions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.regions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    code_region character varying NOT NULL,
    qualified_name character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    departements_count integer DEFAULT 0 NOT NULL,
    epcis_count integer DEFAULT 0 NOT NULL,
    communes_count integer DEFAULT 0 NOT NULL,
    ddfips_count integer DEFAULT 0 NOT NULL,
    collectivities_count integer DEFAULT 0 NOT NULL,
    CONSTRAINT collectivities_count_check CHECK ((collectivities_count >= 0)),
    CONSTRAINT communes_count_check CHECK ((communes_count >= 0)),
    CONSTRAINT ddfips_count_check CHECK ((ddfips_count >= 0)),
    CONSTRAINT departements_count_check CHECK ((departements_count >= 0)),
    CONSTRAINT epcis_count_check CHECK ((epcis_count >= 0))
);


--
-- Name: get_regions_collectivities_count(public.regions); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_regions_collectivities_count(regions public.regions) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "collectivities"
      WHERE  "collectivities"."discarded_at" IS NULL AND (
        (
          "collectivities"."territory_type" = 'Region' AND
          "collectivities"."territory_id"   = regions."id"
        ) OR (
          "collectivities"."territory_type" = 'Commune' AND
          "collectivities"."territory_id" IN (
            SELECT     "communes"."id"
            FROM       "communes"
            INNER JOIN "departements" ON "departements"."code_departement" = "communes"."code_departement"
            WHERE      "departements"."code_region" = regions."code_region"
          )
        ) OR (
          "collectivities"."territory_type" = 'EPCI' AND
          "collectivities"."territory_id" IN (
            SELECT     "epcis"."id"
            FROM       "epcis"
            INNER JOIN "communes" ON "communes"."siren_epci" = "epcis"."siren"
            INNER JOIN "departements" ON "departements"."code_departement" = "communes"."code_departement"
            WHERE      "departements"."code_region" = regions."code_region"
          )
        ) OR (
          "collectivities"."territory_type" = 'Departement' AND
          "collectivities"."territory_id" IN (
            SELECT "departements"."id"
            FROM   "departements"
            WHERE  "departements"."code_region" = regions."code_region"
          )
        )
      )
    );
  END;
$$;


--
-- Name: get_regions_communes_count(public.regions); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_regions_communes_count(regions public.regions) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "communes"
      INNER JOIN "departements" ON "departements"."code_departement" = "communes"."code_departement"
      WHERE      "departements"."code_region" = regions."code_region"
    );
  END;
$$;


--
-- Name: get_regions_ddfips_count(public.regions); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_regions_ddfips_count(regions public.regions) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "ddfips"
      INNER JOIN "departements" ON "departements"."code_departement" = "ddfips"."code_departement"
      WHERE      "departements"."code_region" = regions."code_region"
    );
  END;
$$;


--
-- Name: get_regions_departements_count(public.regions); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_regions_departements_count(regions public.regions) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "departements"
      WHERE  "departements"."code_region" = regions."code_region"
    );
  END;
$$;


--
-- Name: get_regions_epcis_count(public.regions); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_regions_epcis_count(regions public.regions) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT     COUNT(*)
      FROM       "epcis"
      INNER JOIN "departements" ON "departements"."code_departement" = "epcis"."code_departement"
      WHERE      "departements"."code_region" = regions."code_region"
    );
  END;
$$;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_type public.organization_type NOT NULL,
    organization_id uuid NOT NULL,
    inviter_id uuid,
    first_name character varying DEFAULT ''::character varying NOT NULL,
    last_name character varying DEFAULT ''::character varying NOT NULL,
    name character varying DEFAULT ''::character varying NOT NULL,
    super_admin boolean DEFAULT false NOT NULL,
    organization_admin boolean DEFAULT false NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp(6) without time zone,
    remember_created_at timestamp(6) without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp(6) without time zone,
    last_sign_in_at timestamp(6) without time zone,
    current_sign_in_ip character varying,
    last_sign_in_ip character varying,
    confirmation_token character varying,
    confirmed_at timestamp(6) without time zone,
    confirmation_sent_at timestamp(6) without time zone,
    unconfirmed_email character varying,
    failed_attempts integer DEFAULT 0 NOT NULL,
    unlock_token character varying,
    locked_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    invited_at timestamp(6) without time zone,
    discarded_at timestamp(6) without time zone,
    offices_count integer DEFAULT 0 NOT NULL,
    otp_secret character varying,
    otp_method public.otp_method DEFAULT '2fa'::public.otp_method NOT NULL,
    consumed_timestep integer,
    otp_required_for_login boolean DEFAULT true NOT NULL
);


--
-- Name: get_users_offices_count(public.users); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_users_offices_count(users public.users) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT      COUNT(*)
      FROM        "offices"
      INNER JOIN  "office_users" ON "office_users"."office_id" = "offices"."id"
      WHERE       "office_users"."user_id" = users."id"
    );
  END;
$$;


--
-- Name: reset_all_collectivities_counters(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.reset_all_collectivities_counters() RETURNS integer
    LANGUAGE plpgsql
    AS $$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "collectivities"
    SET    "users_count"                = get_collectivities_users_count("collectivities".*),
           "packages_transmitted_count" = get_collectivities_packages_transmitted_count("collectivities".*),
           "packages_unresolved_count"  = get_collectivities_packages_unresolved_count("collectivities".*),
           "packages_assigned_count"    = get_collectivities_packages_assigned_count("collectivities".*),
           "packages_returned_count"    = get_collectivities_packages_returned_count("collectivities".*),
           "reports_incomplete_count"   = get_collectivities_reports_incomplete_count("collectivities".*),
           "reports_packing_count"      = get_collectivities_reports_packing_count("collectivities".*),
           "reports_transmitted_count"  = get_collectivities_reports_transmitted_count("collectivities".*),
           "reports_returned_count"     = get_collectivities_reports_returned_count("collectivities".*),
           "reports_pending_count"      = get_collectivities_reports_pending_count("collectivities".*),
           "reports_debated_count"      = get_collectivities_reports_debated_count("collectivities".*),
           "reports_approved_count"     = get_collectivities_reports_approved_count("collectivities".*),
           "reports_rejected_count"     = get_collectivities_reports_rejected_count("collectivities".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$$;


--
-- Name: reset_all_communes_counters(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.reset_all_communes_counters() RETURNS integer
    LANGUAGE plpgsql
    AS $$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "communes"
    SET    "collectivities_count" = get_communes_collectivities_count("communes".*),
           "offices_count"        = get_communes_offices_count("communes".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$$;


--
-- Name: reset_all_ddfips_counters(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.reset_all_ddfips_counters() RETURNS integer
    LANGUAGE plpgsql
    AS $$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "ddfips"
    SET    "users_count"                = get_ddfips_users_count("ddfips".*),
           "collectivities_count"       = get_ddfips_collectivities_count("ddfips".*),
           "offices_count"              = get_ddfips_offices_count("ddfips".*),
           "packages_transmitted_count" = get_ddfips_packages_transmitted_count("ddfips".*),
           "packages_unresolved_count"  = get_ddfips_packages_unresolved_count("ddfips".*),
           "packages_assigned_count"    = get_ddfips_packages_assigned_count("ddfips".*),
           "packages_returned_count"    = get_ddfips_packages_returned_count("ddfips".*),
           "reports_transmitted_count"  = get_ddfips_reports_transmitted_count("ddfips".*),
           "reports_returned_count"     = get_ddfips_reports_returned_count("ddfips".*),
           "reports_pending_count"      = get_ddfips_reports_pending_count("ddfips".*),
           "reports_debated_count"      = get_ddfips_reports_debated_count("ddfips".*),
           "reports_approved_count"     = get_ddfips_reports_approved_count("ddfips".*),
           "reports_rejected_count"     = get_ddfips_reports_rejected_count("ddfips".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$$;


--
-- Name: reset_all_departements_counters(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.reset_all_departements_counters() RETURNS integer
    LANGUAGE plpgsql
    AS $$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "departements"
    SET    "communes_count"       = get_departements_communes_count("departements".*),
           "epcis_count"          = get_departements_epcis_count("departements".*),
           "ddfips_count"         = get_departements_ddfips_count("departements".*),
           "collectivities_count" = get_departements_collectivities_count("departements".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$$;


--
-- Name: reset_all_dgfips_counters(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.reset_all_dgfips_counters() RETURNS integer
    LANGUAGE plpgsql
    AS $$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "dgfips"
    SET    "users_count"                = get_dgfips_users_count("dgfips".*),
           "packages_transmitted_count" = get_dgfips_packages_transmitted_count("dgfips".*),
           "packages_assigned_count"    = get_dgfips_packages_assigned_count("dgfips".*),
           "packages_returned_count"    = get_dgfips_packages_returned_count("dgfips".*),
           "reports_transmitted_count"  = get_dgfips_reports_transmitted_count("dgfips".*),
           "reports_returned_count"     = get_dgfips_reports_returned_count("dgfips".*),
           "reports_pending_count"      = get_dgfips_reports_pending_count("dgfips".*),
           "reports_debated_count"      = get_dgfips_reports_debated_count("dgfips".*),
           "reports_approved_count"     = get_dgfips_reports_approved_count("dgfips".*),
           "reports_rejected_count"     = get_dgfips_reports_rejected_count("dgfips".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$$;


--
-- Name: reset_all_epcis_counters(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.reset_all_epcis_counters() RETURNS integer
    LANGUAGE plpgsql
    AS $$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "epcis"
    SET    "communes_count"       = get_epcis_communes_count("epcis".*),
           "collectivities_count" = get_epcis_collectivities_count("epcis".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$$;


--
-- Name: reset_all_offices_counters(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.reset_all_offices_counters() RETURNS integer
    LANGUAGE plpgsql
    AS $$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "offices"
    SET    "users_count"            = get_offices_users_count("offices".*),
           "communes_count"         = get_offices_communes_count("offices".*),
           "reports_assigned_count" = get_offices_reports_assigned_count("offices".*),
           "reports_pending_count"  = get_offices_reports_pending_count("offices".*),
           "reports_debated_count"  = get_offices_reports_debated_count("offices".*),
           "reports_approved_count" = get_offices_reports_approved_count("offices".*),
           "reports_rejected_count" = get_offices_reports_rejected_count("offices".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$$;


--
-- Name: reset_all_packages_counters(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.reset_all_packages_counters() RETURNS integer
    LANGUAGE plpgsql
    AS $$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "packages"
    SET    "reports_count"           = get_packages_reports_count("packages".*),
           "reports_approved_count"  = get_packages_reports_approved_count("packages".*),
           "reports_rejected_count"  = get_packages_reports_rejected_count("packages".*),
           "reports_debated_count"   = get_packages_reports_debated_count("packages".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$$;


--
-- Name: reset_all_publishers_counters(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.reset_all_publishers_counters() RETURNS integer
    LANGUAGE plpgsql
    AS $$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "publishers"
    SET    "users_count"                = get_publishers_users_count("publishers".*),
           "collectivities_count"       = get_publishers_collectivities_count("publishers".*),
           "packages_transmitted_count" = get_publishers_packages_transmitted_count("publishers".*),
           "packages_assigned_count"    = get_publishers_packages_assigned_count("publishers".*),
           "packages_returned_count"    = get_publishers_packages_returned_count("publishers".*),
           "reports_transmitted_count"  = get_publishers_reports_transmitted_count("publishers".*),
           "reports_approved_count"     = get_publishers_reports_approved_count("publishers".*),
           "reports_rejected_count"     = get_publishers_reports_rejected_count("publishers".*),
           "reports_debated_count"      = get_publishers_reports_debated_count("publishers".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$$;


--
-- Name: reset_all_regions_counters(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.reset_all_regions_counters() RETURNS integer
    LANGUAGE plpgsql
    AS $$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "regions"
    SET    "communes_count"       = get_regions_communes_count("regions".*),
           "epcis_count"          = get_regions_epcis_count("regions".*),
           "departements_count"   = get_regions_departements_count("regions".*),
           "ddfips_count"         = get_regions_ddfips_count("regions".*),
           "collectivities_count" = get_regions_collectivities_count("regions".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$$;


--
-- Name: reset_all_users_counters(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.reset_all_users_counters() RETURNS integer
    LANGUAGE plpgsql
    AS $$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "users"
    SET    "offices_count" = get_users_offices_count("users".*);

    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RAISE NOTICE 'UPDATE %', affected_rows;

    RETURN affected_rows;
  END;
$$;


--
-- Name: trigger_collectivities_changes(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_collectivities_changes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    -- Reset publishers#collectivities_count
    -- * on creation
    -- * on deletion
    -- * when publisher_id changed (could be NULL)
    -- * when discarded_at changed from NULL
    -- * when discarded_at changed to NULL

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."publisher_id" <> OLD."publisher_id")
    OR (TG_OP = 'UPDATE' AND (NEW."publisher_id" IS NULL) <> (OLD."publisher_id" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."discarded_at" IS NULL) <> (OLD."discarded_at" IS NULL))
    THEN

      UPDATE "publishers"
      SET    "collectivities_count" = get_publishers_collectivities_count("publishers".*)
      WHERE  "publishers"."id" IN (NEW."publisher_id", OLD."publisher_id");

    END IF;

    -- -- Reset all collectivities_count
    -- -- * on creation
    -- -- * on deletion
    -- -- * when territory_id changed
    -- -- * when discarded_at changed from NULL
    -- -- * when discarded_at changed to NULL

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."territory_id" <> OLD."territory_id")
    OR (TG_OP = 'UPDATE' AND (NEW."discarded_at" IS NULL) <> (OLD."discarded_at" IS NULL))
    THEN

      UPDATE  "communes"
      SET     "collectivities_count" = get_communes_collectivities_count("communes".*)
      WHERE   (NEW."territory_type" = 'Commune'     AND "communes"."id" = NEW."territory_id")
        OR    (OLD."territory_type" = 'Commune'     AND "communes"."id" = OLD."territory_id")
        OR    (NEW."territory_type" = 'EPCI'        AND "communes"."siren_epci" IN (SELECT "epcis"."siren" FROM "epcis" WHERE "epcis"."id" = NEW."territory_id"))
        OR    (OLD."territory_type" = 'EPCI'        AND "communes"."siren_epci" IN (SELECT "epcis"."siren" FROM "epcis" WHERE "epcis"."id" = OLD."territory_id"))
        OR    (NEW."territory_type" = 'Departement' AND "communes"."code_departement" IN (SELECT "departements"."code_departement" FROM "departements" WHERE "departements"."id" = NEW."territory_id"))
        OR    (OLD."territory_type" = 'Departement' AND "communes"."code_departement" IN (SELECT "departements"."code_departement" FROM "departements" WHERE "departements"."id" = OLD."territory_id"))
        OR    (NEW."territory_type" = 'Region'      AND "communes"."code_departement" IN (SELECT "departements"."code_departement" FROM "departements" INNER JOIN "regions" ON "regions"."code_region" = "departements"."code_region" WHERE "regions"."id" = NEW."territory_id"))
        OR    (OLD."territory_type" = 'Region'      AND "communes"."code_departement" IN (SELECT "departements"."code_departement" FROM "departements" INNER JOIN "regions" ON "regions"."code_region" = "departements"."code_region" WHERE "regions"."id" = OLD."territory_id"));

      UPDATE  "epcis"
      SET     "collectivities_count" = get_epcis_collectivities_count("epcis".*)
      WHERE   (NEW."territory_type" = 'EPCI'        AND "epcis"."id" = NEW."territory_id")
        OR    (OLD."territory_type" = 'EPCI'        AND "epcis"."id" = OLD."territory_id")
        OR    (NEW."territory_type" = 'Commune'     AND "epcis"."siren" IN (SELECT "communes"."siren_epci" FROM "communes" WHERE "communes"."id" = NEW."territory_id"))
        OR    (OLD."territory_type" = 'Commune'     AND "epcis"."siren" IN (SELECT "communes"."siren_epci" FROM "communes" WHERE "communes"."id" = OLD."territory_id"))
        OR    (NEW."territory_type" = 'Departement' AND "epcis"."siren" IN (SELECT "communes"."siren_epci" FROM "communes" INNER JOIN "departements" ON "departements"."code_departement" = "communes"."code_departement" WHERE "departements"."id" = NEW."territory_id"))
        OR    (OLD."territory_type" = 'Departement' AND "epcis"."siren" IN (SELECT "communes"."siren_epci" FROM "communes" INNER JOIN "departements" ON "departements"."code_departement" = "communes"."code_departement" WHERE "departements"."id" = OLD."territory_id"))
        OR    (NEW."territory_type" = 'Region'      AND "epcis"."siren" IN (SELECT "communes"."siren_epci" FROM "communes" INNER JOIN "departements" ON "departements"."code_departement" = "communes"."code_departement" INNER JOIN "regions" ON "regions"."code_region" = "departements"."code_region" WHERE "regions"."id" = NEW."territory_id"))
        OR    (OLD."territory_type" = 'Region'      AND "epcis"."siren" IN (SELECT "communes"."siren_epci" FROM "communes" INNER JOIN "departements" ON "departements"."code_departement" = "communes"."code_departement" INNER JOIN "regions" ON "regions"."code_region" = "departements"."code_region" WHERE "regions"."id" = OLD."territory_id"));

      UPDATE  "departements"
      SET     "collectivities_count" = get_departements_collectivities_count("departements".*)
      WHERE   (NEW."territory_type" = 'Departement' AND "departements"."id" = NEW."territory_id")
        OR    (OLD."territory_type" = 'Departement' AND "departements"."id" = OLD."territory_id")
        OR    (NEW."territory_type" = 'Commune'     AND "departements"."code_departement" IN (SELECT "communes"."code_departement" FROM "communes" WHERE "communes"."id" = NEW."territory_id"))
        OR    (OLD."territory_type" = 'Commune'     AND "departements"."code_departement" IN (SELECT "communes"."code_departement" FROM "communes" WHERE "communes"."id" = OLD."territory_id"))
        OR    (NEW."territory_type" = 'EPCI'        AND "departements"."code_departement" IN (SELECT "communes"."code_departement" FROM "communes" INNER JOIN "epcis" ON "epcis"."siren" = "communes"."siren_epci" WHERE "epcis"."id" = NEW."territory_id" ))
        OR    (OLD."territory_type" = 'EPCI'        AND "departements"."code_departement" IN (SELECT "communes"."code_departement" FROM "communes" INNER JOIN "epcis" ON "epcis"."siren" = "communes"."siren_epci" WHERE "epcis"."id" = OLD."territory_id" ))
        OR    (NEW."territory_type" = 'Region'      AND "departements"."code_region" IN (SELECT "regions"."code_region" FROM "regions" WHERE "regions"."id" = NEW."territory_id"))
        OR    (OLD."territory_type" = 'Region'      AND "departements"."code_region" IN (SELECT "regions"."code_region" FROM "regions" WHERE "regions"."id" = OLD."territory_id"));

      UPDATE  "regions"
      SET     "collectivities_count" = get_regions_collectivities_count("regions".*)
      WHERE   (NEW."territory_type" = 'Region'      AND "regions"."id" = NEW."territory_id")
        OR    (OLD."territory_type" = 'Region'      AND "regions"."id" = OLD."territory_id")
        OR    (NEW."territory_type" = 'Commune'     AND "regions"."code_region" IN (SELECT "departements"."code_region" FROM "departements" INNER JOIN "communes" ON "communes"."code_departement" = "departements"."code_departement" WHERE "communes"."id" = NEW."territory_id"))
        OR    (OLD."territory_type" = 'Commune'     AND "regions"."code_region" IN (SELECT "departements"."code_region" FROM "departements" INNER JOIN "communes" ON "communes"."code_departement" = "departements"."code_departement" WHERE "communes"."id" = OLD."territory_id"))
        OR    (NEW."territory_type" = 'EPCI'        AND "regions"."code_region" IN (SELECT "departements"."code_region" FROM "departements" INNER JOIN "communes" ON "communes"."code_departement" = "departements"."code_departement" INNER JOIN "epcis" ON "epcis"."siren" = "communes"."siren_epci" WHERE "epcis"."id" = NEW."territory_id"))
        OR    (OLD."territory_type" = 'EPCI'        AND "regions"."code_region" IN (SELECT "departements"."code_region" FROM "departements" INNER JOIN "communes" ON "communes"."code_departement" = "departements"."code_departement" INNER JOIN "epcis" ON "epcis"."siren" = "communes"."siren_epci" WHERE "epcis"."id" = OLD."territory_id"))
        OR    (NEW."territory_type" = 'Departement' AND "regions"."code_region" IN (SELECT "departements"."code_region" FROM "departements" WHERE "departements"."id" = NEW."territory_id"))
        OR    (OLD."territory_type" = 'Departement' AND "regions"."code_region" IN (SELECT "departements"."code_region" FROM "departements" WHERE "departements"."id" = OLD."territory_id"));

      UPDATE  "ddfips"
      SET     "collectivities_count" = get_ddfips_collectivities_count("ddfips".*)
      WHERE   (NEW."territory_type" = 'Commune'     AND "ddfips"."code_departement" IN (SELECT "communes"."code_departement" FROM "communes" WHERE  "communes"."id" = NEW."territory_id" ))
        OR    (OLD."territory_type" = 'Commune'     AND "ddfips"."code_departement" IN (SELECT "communes"."code_departement" FROM "communes" WHERE  "communes"."id" = OLD."territory_id" ))
        OR    (NEW."territory_type" = 'EPCI'        AND "ddfips"."code_departement" IN (SELECT "communes"."code_departement" FROM "communes" INNER JOIN "epcis" ON "epcis"."siren" = "communes"."siren_epci" WHERE "epcis"."id" = NEW."territory_id"))
        OR    (OLD."territory_type" = 'EPCI'        AND "ddfips"."code_departement" IN (SELECT "communes"."code_departement" FROM "communes" INNER JOIN "epcis" ON "epcis"."siren" = "communes"."siren_epci" WHERE "epcis"."id" = OLD."territory_id"))
        OR    (NEW."territory_type" = 'Departement' AND "ddfips"."code_departement" IN (SELECT "departements"."code_departement" FROM "departements" WHERE  "departements"."id" = NEW."territory_id"))
        OR    (OLD."territory_type" = 'Departement' AND "ddfips"."code_departement" IN (SELECT "departements"."code_departement" FROM "departements" WHERE  "departements"."id" = OLD."territory_id"))
        OR    (NEW."territory_type" = 'Region'      AND "ddfips"."code_departement" IN (SELECT "departements"."code_departement" FROM "departements" INNER JOIN "regions" ON "regions"."code_region" = "departements"."code_region" WHERE  "regions"."id" = NEW."territory_id"))
        OR    (OLD."territory_type" = 'Region'      AND "ddfips"."code_departement" IN (SELECT "departements"."code_departement" FROM "departements" INNER JOIN "regions" ON "regions"."code_region" = "departements"."code_region" WHERE  "regions"."id" = OLD."territory_id"));

    END IF;

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$$;


--
-- Name: trigger_communes_changes(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_communes_changes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    -- Reset communes#collectivities_count
    -- * on creation
    -- * when code_departement changed
    -- * when siren_epci changed (could be NULL)

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'UPDATE' AND NEW."code_departement" <> OLD."code_departement")
    OR (TG_OP = 'UPDATE' AND NEW."siren_epci" <> OLD."siren_epci")
    OR (TG_OP = 'UPDATE' AND (NEW."siren_epci" IS NULL) <> (OLD."siren_epci" IS NULL))
    THEN

      UPDATE "communes"
      SET    "collectivities_count" = get_communes_collectivities_count("communes".*)
      WHERE  "communes"."id" = NEW."id";

    END IF;

    -- Reset communes#offices_count
    -- * on creation
    -- * when code_insee changed (it shouldn't)

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'UPDATE' AND NEW."code_insee" <> OLD."code_insee")
    THEN

      UPDATE  "communes"
      SET     "offices_count" = get_communes_offices_count("communes".*)
      WHERE   "communes"."id" = NEW."id";

    END IF;

    -- Reset offices#communes_count
    -- * on creation
    -- * on deletion
    -- * when code_insee changed (it shouldn't)

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."code_insee" <> OLD."code_insee")
    THEN

      UPDATE  "offices"
      SET     "communes_count" = get_offices_communes_count("offices".*)
      WHERE   "offices"."id" IN (
        SELECT "office_communes"."office_id"
        FROM   "office_communes"
        WHERE  "office_communes"."code_insee" IN (NEW."code_insee", OLD."code_insee")
      );

    END IF;

    -- Reset all communes_count & collectivities_count
    -- * on creation
    -- * on deletion
    -- * when code_departement changed
    -- * when siren_epci changed (could be NULL)

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."code_departement" <> OLD."code_departement")
    OR (TG_OP = 'UPDATE' AND NEW."siren_epci" <> OLD."siren_epci")
    OR (TG_OP = 'UPDATE' AND (NEW."siren_epci" IS NULL) <> (OLD."siren_epci" IS NULL))
    THEN

      UPDATE  "epcis"
      SET     "communes_count"       = get_epcis_communes_count("epcis".*),
              "collectivities_count" = get_epcis_collectivities_count("epcis".*)
      WHERE   "epcis"."siren" IN (NEW."siren_epci", OLD."siren_epci");

      UPDATE  "departements"
      SET     "communes_count"       = get_departements_communes_count("departements".*),
              "collectivities_count" = get_departements_collectivities_count("departements".*)
      WHERE   "departements"."code_departement" IN (NEW."code_departement", OLD."code_departement");

      UPDATE  "regions"
      SET     "communes_count"       = get_regions_communes_count("regions".*),
              "collectivities_count" = get_regions_collectivities_count("regions".*)
      WHERE   "regions"."code_region" IN (
                SELECT "departements"."code_region"
                FROM   "departements"
                WHERE  "departements"."code_departement" IN (NEW."code_departement", OLD."code_departement")
              );

      UPDATE  "ddfips"
      SET     "collectivities_count" = get_ddfips_collectivities_count("ddfips".*)
      WHERE   "ddfips"."code_departement" IN (NEW."code_departement", OLD."code_departement");

    END IF;

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$$;


--
-- Name: trigger_ddfips_changes(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_ddfips_changes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    -- Reset self ddfips#collectivities_count
    -- * on creation
    -- * when code_departement changed

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'UPDATE' AND NEW."code_departement" <> OLD."code_departement")
    THEN

      UPDATE "ddfips"
      SET    "collectivities_count" = get_ddfips_collectivities_count("ddfips".*)
      WHERE  "ddfips"."id" = NEW."id";

    END IF;

    -- Reset all ddfips_count
    -- * on creation
    -- * on deletion
    -- * when code_departement changed
    -- * when discarded_at changed from NULL
    -- * when discarded_at changed to NULL

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."code_departement" <> OLD."code_departement")
    OR (TG_OP = 'UPDATE' AND (NEW."discarded_at" IS NULL) <> (OLD."discarded_at" IS NULL))
    THEN

      UPDATE  "departements"
      SET     "ddfips_count" = get_departements_ddfips_count("departements".*)
      WHERE   "departements"."code_departement" IN (NEW."code_departement", OLD."code_departement");

      UPDATE  "regions"
      SET     "ddfips_count" = get_regions_ddfips_count("regions".*)
      WHERE   "regions"."code_region" IN (
                SELECT "departements"."code_region"
                FROM   "departements"
                WHERE  "departements"."code_departement" IN (NEW."code_departement", OLD."code_departement")
              );

    END IF;

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$$;


--
-- Name: trigger_departements_changes(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_departements_changes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    -- Reset self counters
    -- * on creation
    -- * when code_region changed
    -- * when code_departement changed
    -- * when code_departement changed

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'UPDATE' AND NEW."code_region" <> OLD."code_region")
    OR (TG_OP = 'UPDATE' AND NEW."code_departement" <> OLD."code_departement")
    THEN

      UPDATE  "departements"
      SET     "communes_count"       = get_departements_communes_count("departements".*),
              "epcis_count"          = get_departements_epcis_count("departements".*),
              "collectivities_count" = get_departements_collectivities_count("departements".*),
              "ddfips_count"         = get_departements_ddfips_count("departements".*)
      WHERE   "departements"."id" = NEW."id";

    END IF;

    -- Reset all communes_count, departements_count & collectivities_count
    -- * on creation
    -- * on deletion
    -- * when code_region changed
    -- * when code_departement changed

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."code_region" <> OLD."code_region")
    OR (TG_OP = 'UPDATE' AND NEW."code_departement" <> OLD."code_departement")
    THEN

      UPDATE  "communes"
      SET     "collectivities_count" = get_communes_collectivities_count("communes".*)
      WHERE   "communes"."code_departement" IN (NEW."code_departement", OLD."code_departement");

      UPDATE  "epcis"
      SET     "collectivities_count" = get_epcis_collectivities_count("epcis".*)
      WHERE   "epcis"."siren" IN (
                SELECT "communes"."siren_epci"
                FROM   "communes"
                WHERE  "communes"."code_departement" IN (NEW."code_departement", OLD."code_departement")
              );

      UPDATE  "regions"
      SET     "communes_count"       = get_regions_communes_count("regions".*),
              "epcis_count"          = get_regions_epcis_count("regions".*),
              "departements_count"   = get_regions_departements_count("regions".*),
              "collectivities_count" = get_regions_collectivities_count("regions".*),
              "ddfips_count"         = get_regions_ddfips_count("regions".*)
      WHERE   "regions"."code_region" IN (NEW."code_region", OLD."code_region");

      UPDATE  "ddfips"
      SET     "collectivities_count" = get_ddfips_collectivities_count("ddfips".*)
      WHERE   "ddfips"."code_departement" IN (NEW."code_departement", OLD."code_departement");

    END IF;

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$$;


--
-- Name: trigger_epcis_changes(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_epcis_changes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    -- Reset self counters
    -- * on creation
    -- * when siren changed
    -- * when code_departement changed (could be NULL)

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'UPDATE' AND NEW."siren" <> OLD."siren")
    OR (TG_OP = 'UPDATE' AND NEW."code_departement" <> OLD."code_departement")
    OR (TG_OP = 'UPDATE' AND (NEW."code_departement" IS NULL) <> (OLD."code_departement"  IS NULL))
    THEN

      UPDATE  "epcis"
      SET     "communes_count"       = get_epcis_communes_count("epcis".*),
              "collectivities_count" = get_epcis_collectivities_count("epcis".*)
      WHERE   "epcis"."id" = NEW."id";

    END IF;

    -- Reset all epcis_count & collectivities_count
    -- * on creation
    -- * on deletion
    -- * when siren changed
    -- * when code_departement changed (could be NULL)

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."siren" <> OLD."siren")
    OR (TG_OP = 'UPDATE' AND NEW."code_departement" <> OLD."code_departement")
    OR (TG_OP = 'UPDATE' AND (NEW."code_departement" IS NULL) <> (OLD."code_departement"  IS NULL))
    THEN

      UPDATE  "communes"
      SET     "collectivities_count" = get_communes_collectivities_count("communes".*)
      WHERE   "communes"."siren_epci" IN (NEW."siren", OLD."siren");

      UPDATE  "departements"
      SET     "epcis_count"          = get_departements_epcis_count("departements".*),
              "collectivities_count" = get_departements_collectivities_count("departements".*)
      WHERE   "departements"."code_departement" IN (NEW."code_departement", OLD."code_departement")
        OR    "departements"."code_departement" IN (
                SELECT "communes"."code_departement"
                FROM   "communes"
                WHERE  "communes"."siren_epci" IN (NEW."siren", OLD."siren")
              );

      UPDATE  "regions"
      SET     "epcis_count"          = get_regions_epcis_count("regions".*),
              "collectivities_count" = get_regions_collectivities_count("regions".*)
      WHERE   "regions"."code_region" IN (
                SELECT  "departements"."code_region"
                FROM    "departements"
                WHERE   "departements"."code_departement" IN (NEW."code_departement", OLD."code_departement")
                  OR    "departements"."code_departement" IN (
                          SELECT "communes"."code_departement"
                          FROM   "communes"
                          WHERE  "communes"."siren_epci" IN (NEW."siren", OLD."siren")
                        )
              );

      UPDATE  "ddfips"
      SET     "collectivities_count" = get_ddfips_collectivities_count("ddfips".*)
      WHERE   "ddfips"."code_departement" IN (NEW."code_departement", OLD."code_departement")
        OR    "ddfips"."code_departement" IN (
                SELECT "communes"."code_departement"
                FROM   "communes"
                WHERE  "communes"."siren_epci" IN (NEW."siren", OLD."siren")
              );

    END IF;

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$$;


--
-- Name: trigger_office_communes_changes(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_office_communes_changes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN

    UPDATE  "offices"
    SET     "communes_count"         = get_offices_communes_count("offices".*),
            "reports_assigned_count" = get_offices_reports_assigned_count("offices".*),
            "reports_pending_count"  = get_offices_reports_pending_count("offices".*),
            "reports_debated_count"  = get_offices_reports_debated_count("offices".*),
            "reports_approved_count" = get_offices_reports_approved_count("offices".*),
            "reports_rejected_count" = get_offices_reports_rejected_count("offices".*)
    WHERE   "offices"."id" IN (NEW."office_id", OLD."office_id");

    UPDATE  "communes"
    SET     "offices_count" = get_communes_offices_count("communes".*)
    WHERE   "communes"."code_insee" IN (NEW."code_insee", OLD."code_insee");

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$$;


--
-- Name: trigger_office_users_changes(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_office_users_changes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN

    UPDATE  "offices"
    SET     "users_count" = get_offices_users_count("offices".*)
    WHERE   "offices"."id" IN (NEW."office_id", OLD."office_id");

    UPDATE  "users"
    SET     "offices_count" = get_users_offices_count("users".*)
    WHERE   "users"."id" IN (NEW."user_id", OLD."user_id");

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$$;


--
-- Name: trigger_offices_changes(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_offices_changes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    -- Reset all offices_count
    -- * on creation
    -- * on deletion
    -- * when ddfip changed
    -- * when discarded_at changed from NULL
    -- * when discarded_at changed to NULL

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."ddfip_id" <> OLD."ddfip_id")
    OR (TG_OP = 'UPDATE' AND (NEW."discarded_at" IS NULL) <> (OLD."discarded_at" IS NULL))
    THEN

      UPDATE  "ddfips"
      SET     "offices_count" = get_ddfips_offices_count("ddfips".*)
      WHERE   "ddfips"."id" IN (NEW."ddfip_id", OLD."ddfip_id");

    END IF;

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$$;


--
-- Name: trigger_packages_changes(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_packages_changes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN

    -- Reset all packages and reports counts on organizations & offices
    -- * on creation
    -- * on deletion
    -- * when sandbox changed
    -- * when publisher_id changed
    -- * when publisher_id changed from NULL
    -- * when publisher_id changed to NULL
    -- * when (approved_at|returned_at|discarded_at) changed from NULL
    -- * when (approved_at|returned_at|discarded_at) changed to NULL

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."sandbox" <> OLD."sandbox")
    OR (TG_OP = 'UPDATE' AND (NEW."publisher_id" IS DISTINCT FROM OLD."publisher_id"))
    OR (TG_OP = 'UPDATE' AND (NEW."assigned_at" IS NULL) <> (OLD."assigned_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."returned_at" IS NULL) <> (OLD."returned_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."discarded_at" IS NULL) <> (OLD."discarded_at" IS NULL))
    THEN

      UPDATE "publishers"
      SET    "packages_transmitted_count" = get_publishers_packages_transmitted_count("publishers".*),
             "packages_assigned_count"    = get_publishers_packages_assigned_count("publishers".*),
             "packages_returned_count"    = get_publishers_packages_returned_count("publishers".*),
             "reports_transmitted_count"  = get_publishers_reports_transmitted_count("publishers".*),
             "reports_approved_count"     = get_publishers_reports_approved_count("publishers".*),
             "reports_rejected_count"     = get_publishers_reports_rejected_count("publishers".*),
             "reports_debated_count"      = get_publishers_reports_debated_count("publishers".*)
      WHERE  "publishers"."id" IN (NEW."publisher_id", OLD."publisher_id");

      UPDATE "collectivities"
      SET    "packages_transmitted_count" = get_collectivities_packages_transmitted_count("collectivities".*),
             "packages_unresolved_count"  = get_collectivities_packages_unresolved_count("collectivities".*),
             "packages_assigned_count"    = get_collectivities_packages_assigned_count("collectivities".*),
             "packages_returned_count"    = get_collectivities_packages_returned_count("collectivities".*),
             "reports_packing_count"      = get_collectivities_reports_packing_count("collectivities".*),
             "reports_transmitted_count"  = get_collectivities_reports_transmitted_count("collectivities".*),
             "reports_returned_count"     = get_collectivities_reports_returned_count("collectivities".*),
             "reports_pending_count"      = get_collectivities_reports_pending_count("collectivities".*),
             "reports_debated_count"      = get_collectivities_reports_debated_count("collectivities".*),
             "reports_approved_count"     = get_collectivities_reports_approved_count("collectivities".*),
             "reports_rejected_count"     = get_collectivities_reports_rejected_count("collectivities".*)
      WHERE  "collectivities"."id" IN (NEW."collectivity_id", OLD."collectivity_id");

      UPDATE "ddfips"
      SET    "packages_transmitted_count" = get_ddfips_packages_transmitted_count("ddfips".*),
             "packages_unresolved_count"  = get_ddfips_packages_unresolved_count("ddfips".*),
             "packages_assigned_count"    = get_ddfips_packages_assigned_count("ddfips".*),
             "packages_returned_count"    = get_ddfips_packages_returned_count("ddfips".*),
             "reports_transmitted_count"  = get_ddfips_reports_transmitted_count("ddfips".*),
             "reports_returned_count"     = get_ddfips_reports_returned_count("ddfips".*),
             "reports_pending_count"      = get_ddfips_reports_pending_count("ddfips".*),
             "reports_debated_count"      = get_ddfips_reports_debated_count("ddfips".*),
             "reports_approved_count"     = get_ddfips_reports_approved_count("ddfips".*),
             "reports_rejected_count"     = get_ddfips_reports_rejected_count("ddfips".*)
      WHERE  "ddfips"."code_departement" IN (
        SELECT     "communes"."code_departement"
        FROM       "communes"
        INNER JOIN "reports" ON "reports"."code_insee" = "communes"."code_insee"
        WHERE      "reports"."package_id" IN (NEW."id", OLD."id")
      );

      UPDATE "offices"
      SET    "reports_assigned_count" = get_offices_reports_assigned_count("offices".*),
             "reports_pending_count"  = get_offices_reports_pending_count("offices".*),
             "reports_debated_count"  = get_offices_reports_debated_count("offices".*),
             "reports_approved_count" = get_offices_reports_approved_count("offices".*),
             "reports_rejected_count" = get_offices_reports_rejected_count("offices".*)
      WHERE  "offices"."id" IN (
                SELECT     "office_communes"."office_id"
                FROM       "office_communes"
                INNER JOIN "reports" ON "reports"."code_insee" = "office_communes"."code_insee"
                WHERE      "reports"."package_id" IN (NEW."id", OLD."id")
             );

      UPDATE "dgfips"
      SET    "packages_transmitted_count" = get_dgfips_packages_transmitted_count("dgfips".*),
             "packages_assigned_count"    = get_dgfips_packages_assigned_count("dgfips".*),
             "packages_returned_count"    = get_dgfips_packages_returned_count("dgfips".*),
             "reports_transmitted_count"  = get_dgfips_reports_transmitted_count("dgfips".*),
             "reports_returned_count"     = get_dgfips_reports_returned_count("dgfips".*),
             "reports_pending_count"      = get_dgfips_reports_pending_count("dgfips".*),
             "reports_debated_count"      = get_dgfips_reports_debated_count("dgfips".*),
             "reports_approved_count"     = get_dgfips_reports_approved_count("dgfips".*),
             "reports_rejected_count"     = get_dgfips_reports_rejected_count("dgfips".*);

    END IF;

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$$;


--
-- Name: trigger_reports_changes(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_reports_changes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN

    -- Reset all reports counts in packages
    -- * on creation
    -- * on deletion
    -- * when package_id changed
    -- * when package_id changed from NULL
    -- * when package_id changed to NULL
    -- * when (approved_at|rejected_at|debated_at|discarded_at) changed from NULL
    -- * when (approved_at|rejected_at|debated_at|discarded_at) changed to NULL

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."package_id" IS DISTINCT FROM OLD."package_id")
    OR (TG_OP = 'UPDATE' AND (NEW."approved_at" IS NULL) <> (OLD."approved_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."rejected_at" IS NULL) <> (OLD."rejected_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."debated_at" IS NULL) <> (OLD."debated_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."discarded_at" IS NULL) <> (OLD."discarded_at" IS NULL))
    THEN

      UPDATE "packages"
      SET    "reports_count"           = get_packages_reports_count("packages".*),
             "reports_approved_count"  = get_packages_reports_approved_count("packages".*),
             "reports_rejected_count"  = get_packages_reports_rejected_count("packages".*),
             "reports_debated_count"   = get_packages_reports_debated_count("packages".*)
      WHERE  "packages"."id" IN (NEW."package_id", OLD."package_id");

    END IF;

    -- Reset all reports counts in publishers
    -- * on creation
    -- * on deletion
    -- * when publisher_id changed
    -- * when publisher_id changed from NULL
    -- * when publisher_id changed to NULL
    -- * when package_id changed from NULL
    -- * when package_id changed to NULL
    -- * when (approved_at|rejected_at|debated_at|discarded_at) changed from NULL
    -- * when (approved_at|rejected_at|debated_at|discarded_at) changed to NULL

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."publisher_id" IS DISTINCT FROM OLD."publisher_id")
    OR (TG_OP = 'UPDATE' AND (NEW."package_id" IS NULL) <> (OLD."package_id" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."approved_at" IS NULL) <> (OLD."approved_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."rejected_at" IS NULL) <> (OLD."rejected_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."debated_at" IS NULL) <> (OLD."debated_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."discarded_at" IS NULL) <> (OLD."discarded_at" IS NULL))
    THEN

      UPDATE "publishers"
      SET    "reports_transmitted_count" = get_publishers_reports_transmitted_count("publishers".*),
             "reports_approved_count"    = get_publishers_reports_approved_count("publishers".*),
             "reports_rejected_count"    = get_publishers_reports_rejected_count("publishers".*),
             "reports_debated_count"     = get_publishers_reports_debated_count("publishers".*)
      WHERE  "publishers"."id" IN (NEW."publisher_id", OLD."publisher_id");

    END IF;

    -- Reset all reports counts in collectivities
    -- * on creation
    -- * on deletion
    -- * when package_id changed from NULL
    -- * when package_id changed to NULL
    -- * when (completed_at|approved_at|rejected_at|debated_at|discarded_at) changed from NULL
    -- * when (completed_at|approved_at|rejected_at|debated_at|discarded_at) changed to NULL

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND (NEW."package_id" IS NULL) <> (OLD."package_id" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."completed_at" IS NULL) <> (OLD."completed_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."approved_at" IS NULL) <> (OLD."approved_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."rejected_at" IS NULL) <> (OLD."rejected_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."debated_at" IS NULL) <> (OLD."debated_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."discarded_at" IS NULL) <> (OLD."discarded_at" IS NULL))
    THEN

       UPDATE "collectivities"
       SET    "reports_incomplete_count"  = get_collectivities_reports_incomplete_count("collectivities".*),
              "reports_packing_count"     = get_collectivities_reports_packing_count("collectivities".*),
              "reports_transmitted_count" = get_collectivities_reports_transmitted_count("collectivities".*),
              "reports_returned_count"    = get_collectivities_reports_returned_count("collectivities".*),
              "reports_pending_count"     = get_collectivities_reports_pending_count("collectivities".*),
              "reports_debated_count"     = get_collectivities_reports_debated_count("collectivities".*),
              "reports_approved_count"    = get_collectivities_reports_approved_count("collectivities".*),
              "reports_rejected_count"    = get_collectivities_reports_rejected_count("collectivities".*)
       WHERE  "collectivities"."id" IN (NEW."collectivity_id", OLD."collectivity_id");

    END IF;

    -- Reset all reports & packages counts in ddfips &offices
    -- * on creation
    -- * on deletion
    -- * when package_id changed from NULL
    -- * when package_id changed to NULL
    -- * when (approved_at|rejected_at|debated_at|discarded_at) changed from NULL
    -- * when (approved_at|rejected_at|debated_at|discarded_at) changed to NULL

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND (NEW."package_id" IS NULL) <> (OLD."package_id" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."approved_at" IS NULL) <> (OLD."approved_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."rejected_at" IS NULL) <> (OLD."rejected_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."debated_at" IS NULL) <> (OLD."debated_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."discarded_at" IS NULL) <> (OLD."discarded_at" IS NULL))
    THEN

      UPDATE "ddfips"
      SET    "packages_transmitted_count" = get_ddfips_packages_transmitted_count("ddfips".*),
             "packages_unresolved_count"  = get_ddfips_packages_unresolved_count("ddfips".*),
             "packages_assigned_count"    = get_ddfips_packages_assigned_count("ddfips".*),
             "packages_returned_count"    = get_ddfips_packages_returned_count("ddfips".*),
             "reports_transmitted_count"  = get_ddfips_reports_transmitted_count("ddfips".*),
             "reports_returned_count"     = get_ddfips_reports_returned_count("ddfips".*),
             "reports_pending_count"      = get_ddfips_reports_pending_count("ddfips".*),
             "reports_debated_count"      = get_ddfips_reports_debated_count("ddfips".*),
             "reports_approved_count"     = get_ddfips_reports_approved_count("ddfips".*),
             "reports_rejected_count"     = get_ddfips_reports_rejected_count("ddfips".*)
      WHERE  "ddfips"."code_departement" IN (SELECT "communes"."code_departement" FROM "communes" WHERE "communes"."code_insee" = NEW."code_insee")
         OR  "ddfips"."code_departement" IN (SELECT "communes"."code_departement" FROM "communes" WHERE "communes"."code_insee" = OLD."code_insee" );

      UPDATE "offices"
      SET    "reports_assigned_count" = get_offices_reports_assigned_count("offices".*),
             "reports_pending_count"  = get_offices_reports_pending_count("offices".*),
             "reports_debated_count"  = get_offices_reports_debated_count("offices".*),
             "reports_approved_count" = get_offices_reports_approved_count("offices".*),
             "reports_rejected_count" = get_offices_reports_rejected_count("offices".*)
      WHERE  "offices"."id" IN (SELECT "office_communes"."office_id" FROM "office_communes" WHERE "office_communes"."code_insee" = NEW."code_insee")
         OR  "offices"."id" IN (SELECT "office_communes"."office_id" FROM "office_communes" WHERE "office_communes"."code_insee" = OLD."code_insee");

    END IF;

    -- Reset all reports counts in dgfips
    -- * on creation
    -- * on deletion
    -- * when package_id changed from NULL
    -- * when package_id changed to NULL
    -- * when (approved_at|rejected_at|discarded_at) changed from NULL
    -- * when (approved_at|rejected_at|discarded_at) changed to NULL

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND (NEW."package_id" IS NULL) <> (OLD."package_id" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."approved_at" IS NULL) <> (OLD."approved_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."rejected_at" IS NULL) <> (OLD."rejected_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."debated_at" IS NULL) <> (OLD."debated_at" IS NULL))
    OR (TG_OP = 'UPDATE' AND (NEW."discarded_at" IS NULL) <> (OLD."discarded_at" IS NULL))
    THEN

      UPDATE "dgfips"
      SET    "reports_transmitted_count" = get_dgfips_reports_transmitted_count("dgfips".*),
             "reports_returned_count"    = get_dgfips_reports_returned_count("dgfips".*),
             "reports_pending_count"     = get_dgfips_reports_pending_count("dgfips".*),
             "reports_debated_count"     = get_dgfips_reports_debated_count("dgfips".*),
             "reports_approved_count"    = get_dgfips_reports_approved_count("dgfips".*),
             "reports_rejected_count"    = get_dgfips_reports_rejected_count("dgfips".*);

    END IF;

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$$;


--
-- Name: trigger_users_changes(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_users_changes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    -- Reset all users_count
    -- * on creation
    -- * on deletion
    -- * when organization_id changed
    -- * when discarded_at changed from NULL
    -- * when discarded_at changed to NULL

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."organization_id" <> OLD."organization_id")
    OR (TG_OP = 'UPDATE' AND (NEW."discarded_at" IS NULL) <> (OLD."discarded_at" IS NULL))
    THEN

      UPDATE "publishers"
      SET    "users_count" = get_publishers_users_count("publishers".*)
      WHERE  (NEW."organization_type" = 'Publisher' AND "publishers"."id" = NEW."organization_id")
        OR   (OLD."organization_type" = 'Publisher' AND "publishers"."id" = OLD."organization_id");

      UPDATE "collectivities"
      SET    "users_count" = get_collectivities_users_count("collectivities".*)
      WHERE  (NEW."organization_type" = 'Collectivity' AND "collectivities"."id" = NEW."organization_id")
        OR   (OLD."organization_type" = 'Collectivity' AND "collectivities"."id" = OLD."organization_id");

      UPDATE "ddfips"
      SET    "users_count" = get_ddfips_users_count("ddfips".*)
      WHERE  (NEW."organization_type" = 'DDFIP' AND "ddfips"."id" = NEW."organization_id")
        OR   (OLD."organization_type" = 'DDFIP' AND "ddfips"."id" = OLD."organization_id");

      UPDATE "dgfips"
      SET    "users_count" = get_dgfips_users_count("dgfips".*)
      WHERE  (NEW."organization_type" = 'DGFIP' AND "dgfips"."id" = NEW."organization_id")
        OR   (OLD."organization_type" = 'DGFIP' AND "dgfips"."id" = OLD."organization_id");

      UPDATE "offices"
      SET    "users_count" = get_offices_users_count("offices".*)
      WHERE  "offices"."id" IN (
        SELECT "office_users"."office_id"
        FROM   "office_users"
        WHERE  "office_users"."user_id" IN (NEW."id", OLD."id")
      );

    END IF;

    -- result is ignored since this is an AFTER trigger
    RETURN NULL;
  END;
$$;


--
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_attachments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    record_type character varying NOT NULL,
    record_id uuid NOT NULL,
    blob_id uuid NOT NULL,
    name character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_blobs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    key character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata text,
    service_name character varying NOT NULL,
    byte_size bigint NOT NULL,
    checksum character varying,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: active_storage_variant_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_variant_records (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    blob_id uuid NOT NULL,
    variation_digest character varying NOT NULL
);


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: oauth_access_grants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_access_grants (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    resource_owner_id uuid NOT NULL,
    application_id uuid NOT NULL,
    token character varying NOT NULL,
    expires_in integer NOT NULL,
    redirect_uri text NOT NULL,
    scopes character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    revoked_at timestamp(6) without time zone
);


--
-- Name: oauth_access_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_access_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    resource_owner_id uuid,
    application_id uuid NOT NULL,
    token character varying NOT NULL,
    refresh_token character varying,
    expires_in integer,
    scopes character varying,
    created_at timestamp(6) without time zone NOT NULL,
    revoked_at timestamp(6) without time zone,
    previous_refresh_token character varying DEFAULT ''::character varying NOT NULL
);


--
-- Name: oauth_applications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oauth_applications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    uid character varying NOT NULL,
    secret character varying NOT NULL,
    owner_id uuid,
    owner_type character varying,
    redirect_uri text,
    scopes character varying DEFAULT ''::character varying NOT NULL,
    confidential boolean DEFAULT true NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    discarded_at timestamp(6) without time zone,
    sandbox boolean DEFAULT false NOT NULL
);


--
-- Name: office_communes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.office_communes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    office_id uuid NOT NULL,
    code_insee character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: office_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.office_users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    office_id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: report_exonerations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.report_exonerations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    report_id uuid NOT NULL,
    code character varying NOT NULL,
    label character varying NOT NULL,
    status public.exoneration_status NOT NULL,
    base public.exoneration_base NOT NULL,
    code_collectivite public.exoneration_code_collectivite NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: reports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reports (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    collectivity_id uuid NOT NULL,
    publisher_id uuid,
    package_id uuid,
    workshop_id uuid,
    sibling_id character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    approved_at timestamp(6) without time zone,
    rejected_at timestamp(6) without time zone,
    debated_at timestamp(6) without time zone,
    discarded_at timestamp(6) without time zone,
    reference character varying,
    form_type public.form_type NOT NULL,
    anomalies public.anomaly[] NOT NULL,
    priority public.priority DEFAULT 'low'::public.priority NOT NULL,
    code_insee character varying,
    date_constat date,
    enjeu text,
    observations text,
    reponse text,
    situation_annee_majic integer,
    situation_invariant character varying,
    situation_proprietaire character varying,
    situation_numero_ordre_proprietaire character varying,
    situation_parcelle character varying,
    situation_numero_voie character varying,
    situation_indice_repetition character varying,
    situation_libelle_voie character varying,
    situation_code_rivoli character varying,
    situation_adresse character varying,
    situation_numero_batiment character varying,
    situation_numero_escalier character varying,
    situation_numero_niveau character varying,
    situation_numero_porte character varying,
    situation_numero_ordre_porte character varying,
    situation_nature character varying,
    situation_affectation character varying,
    situation_categorie character varying,
    situation_surface_reelle double precision,
    situation_surface_p1 double precision,
    situation_surface_p2 double precision,
    situation_surface_p3 double precision,
    situation_surface_pk1 double precision,
    situation_surface_pk2 double precision,
    situation_surface_ponderee double precision,
    situation_date_mutation character varying,
    situation_coefficient_localisation character varying,
    situation_coefficient_entretien character varying,
    situation_coefficient_situation_generale character varying,
    situation_coefficient_situation_particuliere character varying,
    situation_exoneration character varying,
    proposition_parcelle character varying,
    proposition_numero_voie character varying,
    proposition_indice_repetition character varying,
    proposition_libelle_voie character varying,
    proposition_code_rivoli character varying,
    proposition_adresse character varying,
    proposition_numero_batiment character varying,
    proposition_numero_escalier character varying,
    proposition_numero_niveau character varying,
    proposition_numero_porte character varying,
    proposition_numero_ordre_porte character varying,
    proposition_nature character varying,
    proposition_nature_dependance character varying,
    proposition_affectation character varying,
    proposition_categorie character varying,
    proposition_surface_reelle double precision,
    proposition_surface_p1 double precision,
    proposition_surface_p2 double precision,
    proposition_surface_p3 double precision,
    proposition_surface_pk1 double precision,
    proposition_surface_pk2 double precision,
    proposition_surface_ponderee double precision,
    proposition_coefficient_localisation character varying,
    proposition_coefficient_entretien character varying,
    proposition_coefficient_situation_generale character varying,
    proposition_coefficient_situation_particuliere character varying,
    proposition_exoneration character varying,
    proposition_date_achevement character varying,
    proposition_numero_permis character varying,
    proposition_nature_travaux character varying,
    situation_nature_occupation character varying,
    situation_majoration_rs boolean,
    situation_annee_cfe character varying,
    situation_vacance_fiscale boolean,
    situation_nombre_annees_vacance character varying,
    situation_siren_dernier_occupant character varying,
    situation_nom_dernier_occupant character varying,
    situation_vlf_cfe character varying,
    situation_taxation_base_minimum boolean,
    situation_occupation_annee character varying,
    proposition_nature_occupation character varying,
    proposition_date_occupation date,
    proposition_erreur_tlv boolean,
    proposition_erreur_thlv boolean,
    proposition_meuble_tourisme boolean,
    proposition_majoration_rs boolean,
    proposition_nom_occupant character varying,
    proposition_prenom_occupant character varying,
    proposition_adresse_occupant character varying,
    proposition_numero_siren character varying,
    proposition_nom_societe character varying,
    proposition_nom_enseigne character varying,
    proposition_etablissement_principal boolean,
    proposition_chantier_longue_duree boolean,
    proposition_code_naf character varying,
    proposition_date_debut_activite date,
    transmission_id uuid,
    completed_at timestamp(6) without time zone,
    sandbox boolean DEFAULT false NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: transmissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transmissions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    publisher_id uuid,
    collectivity_id uuid NOT NULL,
    oauth_application_id uuid,
    completed_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    sandbox boolean DEFAULT false NOT NULL
);


--
-- Name: workshops; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workshops (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ddfip_id uuid NOT NULL,
    name character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    discarded_at timestamp(6) without time zone,
    due_on date
);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: active_storage_variant_records active_storage_variant_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT active_storage_variant_records_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: collectivities collectivities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collectivities
    ADD CONSTRAINT collectivities_pkey PRIMARY KEY (id);


--
-- Name: communes communes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.communes
    ADD CONSTRAINT communes_pkey PRIMARY KEY (id);


--
-- Name: ddfips ddfips_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ddfips
    ADD CONSTRAINT ddfips_pkey PRIMARY KEY (id);


--
-- Name: departements departements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departements
    ADD CONSTRAINT departements_pkey PRIMARY KEY (id);


--
-- Name: dgfips dgfips_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dgfips
    ADD CONSTRAINT dgfips_pkey PRIMARY KEY (id);


--
-- Name: epcis epcis_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.epcis
    ADD CONSTRAINT epcis_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_grants oauth_access_grants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_grants
    ADD CONSTRAINT oauth_access_grants_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_tokens oauth_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT oauth_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: oauth_applications oauth_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_applications
    ADD CONSTRAINT oauth_applications_pkey PRIMARY KEY (id);


--
-- Name: office_communes office_communes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.office_communes
    ADD CONSTRAINT office_communes_pkey PRIMARY KEY (id);


--
-- Name: office_users office_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.office_users
    ADD CONSTRAINT office_users_pkey PRIMARY KEY (id);


--
-- Name: offices offices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.offices
    ADD CONSTRAINT offices_pkey PRIMARY KEY (id);


--
-- Name: packages packages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.packages
    ADD CONSTRAINT packages_pkey PRIMARY KEY (id);


--
-- Name: publishers publishers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publishers
    ADD CONSTRAINT publishers_pkey PRIMARY KEY (id);


--
-- Name: regions regions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.regions
    ADD CONSTRAINT regions_pkey PRIMARY KEY (id);


--
-- Name: report_exonerations report_exonerations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_exonerations
    ADD CONSTRAINT report_exonerations_pkey PRIMARY KEY (id);


--
-- Name: reports reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT reports_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: transmissions transmissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transmissions
    ADD CONSTRAINT transmissions_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: workshops workshops_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workshops
    ADD CONSTRAINT workshops_pkey PRIMARY KEY (id);


--
-- Name: index_active_storage_attachments_on_blob_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_storage_attachments_on_blob_id ON public.active_storage_attachments USING btree (blob_id);


--
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON public.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON public.active_storage_blobs USING btree (key);


--
-- Name: index_active_storage_variant_records_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_variant_records_uniqueness ON public.active_storage_variant_records USING btree (blob_id, variation_digest);


--
-- Name: index_collectivities_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collectivities_on_discarded_at ON public.collectivities USING btree (discarded_at);


--
-- Name: index_collectivities_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_collectivities_on_name ON public.collectivities USING btree (name) WHERE (discarded_at IS NULL);


--
-- Name: index_collectivities_on_publisher_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collectivities_on_publisher_id ON public.collectivities USING btree (publisher_id);


--
-- Name: index_collectivities_on_siren; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_collectivities_on_siren ON public.collectivities USING btree (siren) WHERE (discarded_at IS NULL);


--
-- Name: index_collectivities_on_territory; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_collectivities_on_territory ON public.collectivities USING btree (territory_type, territory_id);


--
-- Name: index_communes_on_code_departement; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_communes_on_code_departement ON public.communes USING btree (code_departement);


--
-- Name: index_communes_on_code_insee; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_communes_on_code_insee ON public.communes USING btree (code_insee);


--
-- Name: index_communes_on_siren_epci; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_communes_on_siren_epci ON public.communes USING btree (siren_epci);


--
-- Name: index_ddfips_on_code_departement; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ddfips_on_code_departement ON public.ddfips USING btree (code_departement);


--
-- Name: index_ddfips_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ddfips_on_discarded_at ON public.ddfips USING btree (discarded_at);


--
-- Name: index_ddfips_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ddfips_on_name ON public.ddfips USING btree (name) WHERE (discarded_at IS NULL);


--
-- Name: index_departements_on_code_departement; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_departements_on_code_departement ON public.departements USING btree (code_departement);


--
-- Name: index_departements_on_code_region; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_departements_on_code_region ON public.departements USING btree (code_region);


--
-- Name: index_dgfips_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dgfips_on_discarded_at ON public.dgfips USING btree (discarded_at);


--
-- Name: index_dgfips_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_dgfips_on_name ON public.dgfips USING btree (name) WHERE (discarded_at IS NULL);


--
-- Name: index_epcis_on_code_departement; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_epcis_on_code_departement ON public.epcis USING btree (code_departement);


--
-- Name: index_epcis_on_siren; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_epcis_on_siren ON public.epcis USING btree (siren);


--
-- Name: index_oauth_access_grants_on_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_grants_on_application_id ON public.oauth_access_grants USING btree (application_id);


--
-- Name: index_oauth_access_grants_on_resource_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_grants_on_resource_owner_id ON public.oauth_access_grants USING btree (resource_owner_id);


--
-- Name: index_oauth_access_grants_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_grants_on_token ON public.oauth_access_grants USING btree (token);


--
-- Name: index_oauth_access_tokens_on_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_tokens_on_application_id ON public.oauth_access_tokens USING btree (application_id);


--
-- Name: index_oauth_access_tokens_on_refresh_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_refresh_token ON public.oauth_access_tokens USING btree (refresh_token);


--
-- Name: index_oauth_access_tokens_on_resource_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_access_tokens_on_resource_owner_id ON public.oauth_access_tokens USING btree (resource_owner_id);


--
-- Name: index_oauth_access_tokens_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_token ON public.oauth_access_tokens USING btree (token);


--
-- Name: index_oauth_applications_on_owner_id_and_owner_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_oauth_applications_on_owner_id_and_owner_type ON public.oauth_applications USING btree (owner_id, owner_type);


--
-- Name: index_oauth_applications_on_uid; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_oauth_applications_on_uid ON public.oauth_applications USING btree (uid);


--
-- Name: index_office_communes_on_code_insee; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_office_communes_on_code_insee ON public.office_communes USING btree (code_insee);


--
-- Name: index_office_communes_on_office_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_office_communes_on_office_id ON public.office_communes USING btree (office_id);


--
-- Name: index_office_communes_on_office_id_and_code_insee; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_office_communes_on_office_id_and_code_insee ON public.office_communes USING btree (office_id, code_insee);


--
-- Name: index_office_users_on_office_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_office_users_on_office_id ON public.office_users USING btree (office_id);


--
-- Name: index_office_users_on_office_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_office_users_on_office_id_and_user_id ON public.office_users USING btree (office_id, user_id);


--
-- Name: index_office_users_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_office_users_on_user_id ON public.office_users USING btree (user_id);


--
-- Name: index_offices_on_ddfip_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_offices_on_ddfip_id ON public.offices USING btree (ddfip_id);


--
-- Name: index_offices_on_ddfip_id_and_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_offices_on_ddfip_id_and_name ON public.offices USING btree (ddfip_id, name) WHERE (discarded_at IS NULL);


--
-- Name: index_offices_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_offices_on_discarded_at ON public.offices USING btree (discarded_at);


--
-- Name: index_packages_on_collectivity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_packages_on_collectivity_id ON public.packages USING btree (collectivity_id);


--
-- Name: index_packages_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_packages_on_discarded_at ON public.packages USING btree (discarded_at);


--
-- Name: index_packages_on_publisher_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_packages_on_publisher_id ON public.packages USING btree (publisher_id);


--
-- Name: index_packages_on_reference; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_packages_on_reference ON public.packages USING btree (reference);


--
-- Name: index_packages_on_transmission_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_packages_on_transmission_id ON public.packages USING btree (transmission_id);


--
-- Name: index_publishers_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_publishers_on_discarded_at ON public.publishers USING btree (discarded_at);


--
-- Name: index_publishers_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_publishers_on_name ON public.publishers USING btree (name) WHERE (discarded_at IS NULL);


--
-- Name: index_publishers_on_siren; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_publishers_on_siren ON public.publishers USING btree (siren) WHERE (discarded_at IS NULL);


--
-- Name: index_regions_on_code_region; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_regions_on_code_region ON public.regions USING btree (code_region);


--
-- Name: index_report_exonerations_on_report_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_report_exonerations_on_report_id ON public.report_exonerations USING btree (report_id);


--
-- Name: index_reports_on_collectivity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reports_on_collectivity_id ON public.reports USING btree (collectivity_id);


--
-- Name: index_reports_on_package_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reports_on_package_id ON public.reports USING btree (package_id);


--
-- Name: index_reports_on_publisher_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reports_on_publisher_id ON public.reports USING btree (publisher_id);


--
-- Name: index_reports_on_reference; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_reports_on_reference ON public.reports USING btree (reference);


--
-- Name: index_reports_on_sibling_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reports_on_sibling_id ON public.reports USING btree (sibling_id);


--
-- Name: index_reports_on_transmission_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reports_on_transmission_id ON public.reports USING btree (transmission_id);


--
-- Name: index_reports_on_workshop_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_reports_on_workshop_id ON public.reports USING btree (workshop_id);


--
-- Name: index_transmissions_on_collectivity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_transmissions_on_collectivity_id ON public.transmissions USING btree (collectivity_id);


--
-- Name: index_transmissions_on_oauth_application_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_transmissions_on_oauth_application_id ON public.transmissions USING btree (oauth_application_id);


--
-- Name: index_transmissions_on_publisher_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_transmissions_on_publisher_id ON public.transmissions USING btree (publisher_id);


--
-- Name: index_transmissions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_transmissions_on_user_id ON public.transmissions USING btree (user_id);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON public.users USING btree (confirmation_token);


--
-- Name: index_users_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_discarded_at ON public.users USING btree (discarded_at);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email) WHERE (discarded_at IS NULL);


--
-- Name: index_users_on_inviter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_inviter_id ON public.users USING btree (inviter_id);


--
-- Name: index_users_on_organization; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_organization ON public.users USING btree (organization_type, organization_id);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_users_on_unlock_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_unlock_token ON public.users USING btree (unlock_token);


--
-- Name: index_workshops_on_ddfip_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_workshops_on_ddfip_id ON public.workshops USING btree (ddfip_id);


--
-- Name: index_workshops_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_workshops_on_discarded_at ON public.workshops USING btree (discarded_at);


--
-- Name: singleton_dgfip_constraint; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX singleton_dgfip_constraint ON public.dgfips USING btree ((1));


--
-- Name: collectivities trigger_collectivities_changes; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_collectivities_changes AFTER INSERT OR DELETE OR UPDATE ON public.collectivities FOR EACH ROW EXECUTE FUNCTION public.trigger_collectivities_changes();


--
-- Name: communes trigger_communes_changes; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_communes_changes AFTER INSERT OR DELETE OR UPDATE ON public.communes FOR EACH ROW EXECUTE FUNCTION public.trigger_communes_changes();


--
-- Name: ddfips trigger_ddfips_changes; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_ddfips_changes AFTER INSERT OR DELETE OR UPDATE ON public.ddfips FOR EACH ROW EXECUTE FUNCTION public.trigger_ddfips_changes();


--
-- Name: departements trigger_departements_changes; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_departements_changes AFTER INSERT OR DELETE OR UPDATE ON public.departements FOR EACH ROW EXECUTE FUNCTION public.trigger_departements_changes();


--
-- Name: epcis trigger_epcis_changes; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_epcis_changes AFTER INSERT OR DELETE OR UPDATE ON public.epcis FOR EACH ROW EXECUTE FUNCTION public.trigger_epcis_changes();


--
-- Name: office_communes trigger_office_communes_changes; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_office_communes_changes AFTER INSERT OR DELETE ON public.office_communes FOR EACH ROW EXECUTE FUNCTION public.trigger_office_communes_changes();


--
-- Name: office_users trigger_office_users_changes; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_office_users_changes AFTER INSERT OR DELETE ON public.office_users FOR EACH ROW EXECUTE FUNCTION public.trigger_office_users_changes();


--
-- Name: offices trigger_offices_changes; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_offices_changes AFTER INSERT OR DELETE OR UPDATE ON public.offices FOR EACH ROW EXECUTE FUNCTION public.trigger_offices_changes();


--
-- Name: packages trigger_packages_changes; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_packages_changes AFTER INSERT OR DELETE OR UPDATE ON public.packages FOR EACH ROW EXECUTE FUNCTION public.trigger_packages_changes();


--
-- Name: reports trigger_reports_changes; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_reports_changes AFTER INSERT OR DELETE OR UPDATE ON public.reports FOR EACH ROW EXECUTE FUNCTION public.trigger_reports_changes();


--
-- Name: users trigger_users_changes; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_users_changes AFTER INSERT OR DELETE OR UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.trigger_users_changes();


--
-- Name: reports fk_rails_05f6a25318; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT fk_rails_05f6a25318 FOREIGN KEY (workshop_id) REFERENCES public.workshops(id) ON DELETE SET NULL;


--
-- Name: communes fk_rails_12e546a056; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.communes
    ADD CONSTRAINT fk_rails_12e546a056 FOREIGN KEY (siren_epci) REFERENCES public.epcis(siren) ON UPDATE CASCADE;


--
-- Name: departements fk_rails_16088f7822; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departements
    ADD CONSTRAINT fk_rails_16088f7822 FOREIGN KEY (code_region) REFERENCES public.regions(code_region);


--
-- Name: offices fk_rails_191c3cbfbc; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.offices
    ADD CONSTRAINT fk_rails_191c3cbfbc FOREIGN KEY (ddfip_id) REFERENCES public.ddfips(id) ON DELETE CASCADE;


--
-- Name: transmissions fk_rails_19db02e97a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transmissions
    ADD CONSTRAINT fk_rails_19db02e97a FOREIGN KEY (collectivity_id) REFERENCES public.collectivities(id);


--
-- Name: oauth_access_grants fk_rails_330c32d8d9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_grants
    ADD CONSTRAINT fk_rails_330c32d8d9 FOREIGN KEY (resource_owner_id) REFERENCES public.publishers(id) ON DELETE CASCADE;


--
-- Name: office_users fk_rails_34d1da443b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.office_users
    ADD CONSTRAINT fk_rails_34d1da443b FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: reports fk_rails_4674dd48a1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT fk_rails_4674dd48a1 FOREIGN KEY (package_id) REFERENCES public.packages(id) ON DELETE CASCADE;


--
-- Name: reports fk_rails_4983720dc4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT fk_rails_4983720dc4 FOREIGN KEY (transmission_id) REFERENCES public.transmissions(id);


--
-- Name: reports fk_rails_4bfc052571; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT fk_rails_4bfc052571 FOREIGN KEY (publisher_id) REFERENCES public.publishers(id) ON DELETE CASCADE;


--
-- Name: packages fk_rails_4d9176af60; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.packages
    ADD CONSTRAINT fk_rails_4d9176af60 FOREIGN KEY (transmission_id) REFERENCES public.transmissions(id);


--
-- Name: office_users fk_rails_528e1db265; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.office_users
    ADD CONSTRAINT fk_rails_528e1db265 FOREIGN KEY (office_id) REFERENCES public.offices(id) ON DELETE CASCADE;


--
-- Name: epcis fk_rails_606b12a072; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.epcis
    ADD CONSTRAINT fk_rails_606b12a072 FOREIGN KEY (code_departement) REFERENCES public.departements(code_departement);


--
-- Name: transmissions fk_rails_65784bea92; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transmissions
    ADD CONSTRAINT fk_rails_65784bea92 FOREIGN KEY (oauth_application_id) REFERENCES public.oauth_applications(id);


--
-- Name: oauth_access_tokens fk_rails_732cb83ab7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT fk_rails_732cb83ab7 FOREIGN KEY (application_id) REFERENCES public.oauth_applications(id);


--
-- Name: report_exonerations fk_rails_763b0b7e91; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.report_exonerations
    ADD CONSTRAINT fk_rails_763b0b7e91 FOREIGN KEY (report_id) REFERENCES public.reports(id) ON DELETE CASCADE;


--
-- Name: packages fk_rails_880b85e679; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.packages
    ADD CONSTRAINT fk_rails_880b85e679 FOREIGN KEY (publisher_id) REFERENCES public.publishers(id) ON DELETE CASCADE;


--
-- Name: collectivities fk_rails_8f20c81d41; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collectivities
    ADD CONSTRAINT fk_rails_8f20c81d41 FOREIGN KEY (publisher_id) REFERENCES public.publishers(id) ON DELETE SET NULL;


--
-- Name: active_storage_variant_records fk_rails_993965df05; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT fk_rails_993965df05 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: transmissions fk_rails_a3319cd57a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transmissions
    ADD CONSTRAINT fk_rails_a3319cd57a FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: reports fk_rails_a7a6115818; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT fk_rails_a7a6115818 FOREIGN KEY (collectivity_id) REFERENCES public.collectivities(id) ON DELETE CASCADE;


--
-- Name: office_communes fk_rails_b43ade12e1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.office_communes
    ADD CONSTRAINT fk_rails_b43ade12e1 FOREIGN KEY (office_id) REFERENCES public.offices(id) ON DELETE CASCADE;


--
-- Name: transmissions fk_rails_b443b039c7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transmissions
    ADD CONSTRAINT fk_rails_b443b039c7 FOREIGN KEY (publisher_id) REFERENCES public.publishers(id);


--
-- Name: oauth_access_grants fk_rails_b4b53e07b8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_grants
    ADD CONSTRAINT fk_rails_b4b53e07b8 FOREIGN KEY (application_id) REFERENCES public.oauth_applications(id);


--
-- Name: active_storage_attachments fk_rails_c3b3935057; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT fk_rails_c3b3935057 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: communes fk_rails_ca34c89446; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.communes
    ADD CONSTRAINT fk_rails_ca34c89446 FOREIGN KEY (code_departement) REFERENCES public.departements(code_departement);


--
-- Name: workshops fk_rails_d255d96eba; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workshops
    ADD CONSTRAINT fk_rails_d255d96eba FOREIGN KEY (ddfip_id) REFERENCES public.ddfips(id) ON DELETE CASCADE;


--
-- Name: packages fk_rails_d338b343c7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.packages
    ADD CONSTRAINT fk_rails_d338b343c7 FOREIGN KEY (collectivity_id) REFERENCES public.collectivities(id) ON DELETE CASCADE;


--
-- Name: ddfips fk_rails_da3790c57d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ddfips
    ADD CONSTRAINT fk_rails_da3790c57d FOREIGN KEY (code_departement) REFERENCES public.departements(code_departement);


--
-- Name: oauth_access_tokens fk_rails_ee63f25419; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT fk_rails_ee63f25419 FOREIGN KEY (resource_owner_id) REFERENCES public.publishers(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20230412064105'),
('20230412064138'),
('20230412064141'),
('20230412064148'),
('20230412064153'),
('20230412064211'),
('20230412064216'),
('20230412064223'),
('20230412064230'),
('20230412064717'),
('20230412064725'),
('20230412064729'),
('20230412064833'),
('20230412064850'),
('20230514161159'),
('20230516080055'),
('20230516173340'),
('20230517093540'),
('20230601080000'),
('20230601080335'),
('20230601080341'),
('20230601080346'),
('20230601093936'),
('20230605122559'),
('20230605130656'),
('20230607183851'),
('20230608074912'),
('20230608152933'),
('20230609124040'),
('20230611213727'),
('20230619095430'),
('20230622073103'),
('20230622135614'),
('20230628131702'),
('20230705064157'),
('20230727083603'),
('20230728085901'),
('20230823083541'),
('20230823125725'),
('20230823132126'),
('20230829135011'),
('20230829153550'),
('20230830170839'),
('20230901084754'),
('20230904105215'),
('20230905092502'),
('20230907151950'),
('20230914083547'),
('20230914100806'),
('20230921145204'),
('20230922120732'),
('20230922132331'),
('20230922140136'),
('20230926152855'),
('20230928141212'),
('20230928162717'),
('20230929034420'),
('20231004101953'),
('20231016144839');


