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
-- Name: collectivity_territory_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.collectivity_territory_type AS ENUM (
    'Commune',
    'EPCI',
    'Departement',
    'Region'
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
-- Name: office_action; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.office_action AS ENUM (
    'evaluation_hab',
    'evaluation_eco',
    'occupation_hab',
    'occupation_eco'
);


--
-- Name: user_organization_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.user_organization_type AS ENUM (
    'Collectivity',
    'Publisher',
    'DDFIP'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

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
-- Name: get_collectivities_count_in_communes(public.communes); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_collectivities_count_in_communes(communes public.communes) RETURNS integer
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
    CONSTRAINT collectivities_count_check CHECK ((collectivities_count >= 0)),
    CONSTRAINT offices_count_check CHECK ((offices_count >= 0)),
    CONSTRAINT users_count_check CHECK ((users_count >= 0))
);


--
-- Name: get_collectivities_count_in_ddfips(public.ddfips); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_collectivities_count_in_ddfips(ddfips public.ddfips) RETURNS integer
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
-- Name: get_collectivities_count_in_departements(public.departements); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_collectivities_count_in_departements(departements public.departements) RETURNS integer
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
-- Name: get_collectivities_count_in_epcis(public.epcis); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_collectivities_count_in_epcis(epcis public.epcis) RETURNS integer
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
-- Name: publishers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.publishers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    siren character varying NOT NULL,
    email character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    discarded_at timestamp(6) without time zone,
    users_count integer DEFAULT 0 NOT NULL,
    collectivities_count integer DEFAULT 0 NOT NULL,
    CONSTRAINT collectivities_count_check CHECK ((collectivities_count >= 0)),
    CONSTRAINT users_count_check CHECK ((users_count >= 0))
);


--
-- Name: get_collectivities_count_in_publishers(public.publishers); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_collectivities_count_in_publishers(publishers public.publishers) RETURNS integer
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
-- Name: get_collectivities_count_in_regions(public.regions); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_collectivities_count_in_regions(regions public.regions) RETURNS integer
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
-- Name: get_communes_count_in_departements(public.departements); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_communes_count_in_departements(departements public.departements) RETURNS integer
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
-- Name: get_communes_count_in_epcis(public.epcis); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_communes_count_in_epcis(epcis public.epcis) RETURNS integer
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
    action public.office_action NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    discarded_at timestamp(6) without time zone,
    users_count integer DEFAULT 0 NOT NULL,
    communes_count integer DEFAULT 0 NOT NULL
);


--
-- Name: get_communes_count_in_offices(public.offices); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_communes_count_in_offices(offices public.offices) RETURNS integer
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
-- Name: get_communes_count_in_regions(public.regions); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_communes_count_in_regions(regions public.regions) RETURNS integer
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
-- Name: get_ddfips_count_in_departements(public.departements); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_ddfips_count_in_departements(departements public.departements) RETURNS integer
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
-- Name: get_ddfips_count_in_regions(public.regions); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_ddfips_count_in_regions(regions public.regions) RETURNS integer
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
-- Name: get_departements_count_in_regions(public.regions); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_departements_count_in_regions(regions public.regions) RETURNS integer
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
-- Name: get_epcis_count_in_departements(public.departements); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_epcis_count_in_departements(departements public.departements) RETURNS integer
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
-- Name: get_epcis_count_in_regions(public.regions); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_epcis_count_in_regions(regions public.regions) RETURNS integer
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
-- Name: get_offices_count_in_communes(public.communes); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_offices_count_in_communes(communes public.communes) RETURNS integer
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
-- Name: get_offices_count_in_ddfips(public.ddfips); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_offices_count_in_ddfips(ddfips public.ddfips) RETURNS integer
    LANGUAGE plpgsql
    AS $$
  BEGIN
    RETURN (
      SELECT COUNT(*)
      FROM   "offices"
      WHERE  "offices"."ddfip_id" = ddfips."id"
    );
  END;
$$;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organization_type public.user_organization_type NOT NULL,
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
    offices_count integer DEFAULT 0 NOT NULL
);


--
-- Name: get_offices_count_in_users(public.users); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_offices_count_in_users(users public.users) RETURNS integer
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
-- Name: collectivities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.collectivities (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    territory_type public.collectivity_territory_type NOT NULL,
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
    CONSTRAINT users_count_check CHECK ((users_count >= 0))
);


--
-- Name: get_users_count_in_collectivities(public.collectivities); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_users_count_in_collectivities(collectivities public.collectivities) RETURNS integer
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
-- Name: get_users_count_in_ddfips(public.ddfips); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_users_count_in_ddfips(ddfips public.ddfips) RETURNS integer
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
-- Name: get_users_count_in_offices(public.offices); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_users_count_in_offices(offices public.offices) RETURNS integer
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
-- Name: get_users_count_in_publishers(public.publishers); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_users_count_in_publishers(publishers public.publishers) RETURNS integer
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
-- Name: reset_all_collectivities_counters(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.reset_all_collectivities_counters() RETURNS integer
    LANGUAGE plpgsql
    AS $$
  DECLARE
    affected_rows integer;
  BEGIN
    UPDATE "collectivities"
    SET    "users_count" = get_users_count_in_collectivities("collectivities".*);

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
    SET    "collectivities_count" = get_collectivities_count_in_communes("communes".*),
           "offices_count"        = get_offices_count_in_communes("communes".*);

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
    SET    "users_count"          = get_users_count_in_ddfips("ddfips".*),
           "collectivities_count" = get_collectivities_count_in_ddfips("ddfips".*),
           "offices_count"        = get_offices_count_in_ddfips("ddfips".*);

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
    SET    "communes_count"       = get_communes_count_in_departements("departements".*),
           "epcis_count"          = get_epcis_count_in_departements("departements".*),
           "ddfips_count"         = get_ddfips_count_in_departements("departements".*),
           "collectivities_count" = get_collectivities_count_in_departements("departements".*);

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
    SET    "communes_count"       = get_communes_count_in_epcis("epcis".*),
           "collectivities_count" = get_collectivities_count_in_epcis("epcis".*);

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
    SET    "users_count"    = get_users_count_in_offices("offices".*),
           "communes_count" = get_communes_count_in_offices("offices".*);

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
    SET    "users_count"          = get_users_count_in_publishers("publishers".*),
           "collectivities_count" = get_collectivities_count_in_publishers("publishers".*);

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
    SET    "communes_count"       = get_communes_count_in_regions("regions".*),
           "epcis_count"          = get_epcis_count_in_regions("regions".*),
           "departements_count"   = get_departements_count_in_regions("regions".*),
           "ddfips_count"         = get_ddfips_count_in_regions("regions".*),
           "collectivities_count" = get_collectivities_count_in_regions("regions".*);

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
    SET    "offices_count" = get_offices_count_in_users("users".*);

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
      SET    "collectivities_count" = get_collectivities_count_in_publishers("publishers".*)
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
      SET     "collectivities_count" = get_collectivities_count_in_communes("communes".*)
      WHERE   (NEW."territory_type" = 'Commune'     AND "communes"."id" = NEW."territory_id")
        OR    (OLD."territory_type" = 'Commune'     AND "communes"."id" = OLD."territory_id")
        OR    (NEW."territory_type" = 'EPCI'        AND "communes"."siren_epci" IN (SELECT "epcis"."siren" FROM "epcis" WHERE "epcis"."id" = NEW."territory_id"))
        OR    (OLD."territory_type" = 'EPCI'        AND "communes"."siren_epci" IN (SELECT "epcis"."siren" FROM "epcis" WHERE "epcis"."id" = OLD."territory_id"))
        OR    (NEW."territory_type" = 'Departement' AND "communes"."code_departement" IN (SELECT "departements"."code_departement" FROM "departements" WHERE "departements"."id" = NEW."territory_id"))
        OR    (OLD."territory_type" = 'Departement' AND "communes"."code_departement" IN (SELECT "departements"."code_departement" FROM "departements" WHERE "departements"."id" = OLD."territory_id"))
        OR    (NEW."territory_type" = 'Region'      AND "communes"."code_departement" IN (SELECT "departements"."code_departement" FROM "departements" INNER JOIN "regions" ON "regions"."code_region" = "departements"."code_region" WHERE "regions"."id" = NEW."territory_id"))
        OR    (OLD."territory_type" = 'Region'      AND "communes"."code_departement" IN (SELECT "departements"."code_departement" FROM "departements" INNER JOIN "regions" ON "regions"."code_region" = "departements"."code_region" WHERE "regions"."id" = OLD."territory_id"));

      UPDATE  "epcis"
      SET     "collectivities_count" = get_collectivities_count_in_epcis("epcis".*)
      WHERE   (NEW."territory_type" = 'EPCI'        AND "epcis"."id" = NEW."territory_id")
        OR    (OLD."territory_type" = 'EPCI'        AND "epcis"."id" = OLD."territory_id")
        OR    (NEW."territory_type" = 'Commune'     AND "epcis"."siren" IN (SELECT "communes"."siren_epci" FROM "communes" WHERE "communes"."id" = NEW."territory_id"))
        OR    (OLD."territory_type" = 'Commune'     AND "epcis"."siren" IN (SELECT "communes"."siren_epci" FROM "communes" WHERE "communes"."id" = OLD."territory_id"))
        OR    (NEW."territory_type" = 'Departement' AND "epcis"."siren" IN (SELECT "communes"."siren_epci" FROM "communes" INNER JOIN "departements" ON "departements"."code_departement" = "communes"."code_departement" WHERE "departements"."id" = NEW."territory_id"))
        OR    (OLD."territory_type" = 'Departement' AND "epcis"."siren" IN (SELECT "communes"."siren_epci" FROM "communes" INNER JOIN "departements" ON "departements"."code_departement" = "communes"."code_departement" WHERE "departements"."id" = OLD."territory_id"))
        OR    (NEW."territory_type" = 'Region'      AND "epcis"."siren" IN (SELECT "communes"."siren_epci" FROM "communes" INNER JOIN "departements" ON "departements"."code_departement" = "communes"."code_departement" INNER JOIN "regions" ON "regions"."code_region" = "departements"."code_region" WHERE "regions"."id" = NEW."territory_id"))
        OR    (OLD."territory_type" = 'Region'      AND "epcis"."siren" IN (SELECT "communes"."siren_epci" FROM "communes" INNER JOIN "departements" ON "departements"."code_departement" = "communes"."code_departement" INNER JOIN "regions" ON "regions"."code_region" = "departements"."code_region" WHERE "regions"."id" = OLD."territory_id"));

      UPDATE  "departements"
      SET     "collectivities_count" = get_collectivities_count_in_departements("departements".*)
      WHERE   (NEW."territory_type" = 'Departement' AND "departements"."id" = NEW."territory_id")
        OR    (OLD."territory_type" = 'Departement' AND "departements"."id" = OLD."territory_id")
        OR    (NEW."territory_type" = 'Commune'     AND "departements"."code_departement" IN (SELECT "communes"."code_departement" FROM "communes" WHERE "communes"."id" = NEW."territory_id"))
        OR    (OLD."territory_type" = 'Commune'     AND "departements"."code_departement" IN (SELECT "communes"."code_departement" FROM "communes" WHERE "communes"."id" = OLD."territory_id"))
        OR    (NEW."territory_type" = 'EPCI'        AND "departements"."code_departement" IN (SELECT "communes"."code_departement" FROM "communes" INNER JOIN "epcis" ON "epcis"."siren" = "communes"."siren_epci" WHERE "epcis"."id" = NEW."territory_id" ))
        OR    (OLD."territory_type" = 'EPCI'        AND "departements"."code_departement" IN (SELECT "communes"."code_departement" FROM "communes" INNER JOIN "epcis" ON "epcis"."siren" = "communes"."siren_epci" WHERE "epcis"."id" = OLD."territory_id" ))
        OR    (NEW."territory_type" = 'Region'      AND "departements"."code_region" IN (SELECT "regions"."code_region" FROM "regions" WHERE "regions"."id" = NEW."territory_id"))
        OR    (OLD."territory_type" = 'Region'      AND "departements"."code_region" IN (SELECT "regions"."code_region" FROM "regions" WHERE "regions"."id" = OLD."territory_id"));

      UPDATE  "regions"
      SET     "collectivities_count" = get_collectivities_count_in_regions("regions".*)
      WHERE   (NEW."territory_type" = 'Region'      AND "regions"."id" = NEW."territory_id")
        OR    (OLD."territory_type" = 'Region'      AND "regions"."id" = OLD."territory_id")
        OR    (NEW."territory_type" = 'Commune'     AND "regions"."code_region" IN (SELECT "departements"."code_region" FROM "departements" INNER JOIN "communes" ON "communes"."code_departement" = "departements"."code_departement" WHERE "communes"."id" = NEW."territory_id"))
        OR    (OLD."territory_type" = 'Commune'     AND "regions"."code_region" IN (SELECT "departements"."code_region" FROM "departements" INNER JOIN "communes" ON "communes"."code_departement" = "departements"."code_departement" WHERE "communes"."id" = OLD."territory_id"))
        OR    (NEW."territory_type" = 'EPCI'        AND "regions"."code_region" IN (SELECT "departements"."code_region" FROM "departements" INNER JOIN "communes" ON "communes"."code_departement" = "departements"."code_departement" INNER JOIN "epcis" ON "epcis"."siren" = "communes"."siren_epci" WHERE "epcis"."id" = NEW."territory_id"))
        OR    (OLD."territory_type" = 'EPCI'        AND "regions"."code_region" IN (SELECT "departements"."code_region" FROM "departements" INNER JOIN "communes" ON "communes"."code_departement" = "departements"."code_departement" INNER JOIN "epcis" ON "epcis"."siren" = "communes"."siren_epci" WHERE "epcis"."id" = OLD."territory_id"))
        OR    (NEW."territory_type" = 'Departement' AND "regions"."code_region" IN (SELECT "departements"."code_region" FROM "departements" WHERE "departements"."id" = NEW."territory_id"))
        OR    (OLD."territory_type" = 'Departement' AND "regions"."code_region" IN (SELECT "departements"."code_region" FROM "departements" WHERE "departements"."id" = OLD."territory_id"));

      UPDATE  "ddfips"
      SET     "collectivities_count" = get_collectivities_count_in_ddfips("ddfips".*)
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
      SET    "collectivities_count" = get_collectivities_count_in_communes("communes".*)
      WHERE  "communes"."id" = NEW."id";

    END IF;

    -- Reset communes#offices_count
    -- * on creation
    -- * when code_insee changed (it shouldn't)

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'UPDATE' AND NEW."code_insee" <> OLD."code_insee")
    THEN

      UPDATE  "communes"
      SET     "offices_count" = get_offices_count_in_communes("communes".*)
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
      SET     "communes_count" = get_communes_count_in_offices("offices".*)
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
      SET     "communes_count"       = get_communes_count_in_epcis("epcis".*),
              "collectivities_count" = get_collectivities_count_in_epcis("epcis".*)
      WHERE   "epcis"."siren" IN (NEW."siren_epci", OLD."siren_epci");

      UPDATE  "departements"
      SET     "communes_count"       = get_communes_count_in_departements("departements".*),
              "collectivities_count" = get_collectivities_count_in_departements("departements".*)
      WHERE   "departements"."code_departement" IN (NEW."code_departement", OLD."code_departement");

      UPDATE  "regions"
      SET     "communes_count"       = get_communes_count_in_regions("regions".*),
              "collectivities_count" = get_collectivities_count_in_regions("regions".*)
      WHERE   "regions"."code_region" IN (
                SELECT "departements"."code_region"
                FROM   "departements"
                WHERE  "departements"."code_departement" IN (NEW."code_departement", OLD."code_departement")
              );

      UPDATE  "ddfips"
      SET     "collectivities_count" = get_collectivities_count_in_ddfips("ddfips".*)
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
      SET    "collectivities_count" = get_collectivities_count_in_ddfips("ddfips".*)
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
      SET     "ddfips_count" = get_ddfips_count_in_departements("departements".*)
      WHERE   "departements"."code_departement" IN (NEW."code_departement", OLD."code_departement");

      UPDATE  "regions"
      SET     "ddfips_count" = get_ddfips_count_in_regions("regions".*)
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
      SET     "communes_count"       = get_communes_count_in_departements("departements".*),
              "epcis_count"          = get_epcis_count_in_departements("departements".*),
              "collectivities_count" = get_collectivities_count_in_departements("departements".*),
              "ddfips_count"         = get_ddfips_count_in_departements("departements".*)
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
      SET     "collectivities_count" = get_collectivities_count_in_communes("communes".*)
      WHERE   "communes"."code_departement" IN (NEW."code_departement", OLD."code_departement");

      UPDATE  "epcis"
      SET     "collectivities_count" = get_collectivities_count_in_epcis("epcis".*)
      WHERE   "epcis"."siren" IN (
                SELECT "communes"."siren_epci"
                FROM   "communes"
                WHERE  "communes"."code_departement" IN (NEW."code_departement", OLD."code_departement")
              );

      UPDATE  "regions"
      SET     "communes_count"       = get_communes_count_in_regions("regions".*),
              "epcis_count"          = get_epcis_count_in_regions("regions".*),
              "departements_count"   = get_departements_count_in_regions("regions".*),
              "collectivities_count" = get_collectivities_count_in_regions("regions".*),
              "ddfips_count"         = get_ddfips_count_in_regions("regions".*)
      WHERE   "regions"."code_region" IN (NEW."code_region", OLD."code_region");

      UPDATE  "ddfips"
      SET     "collectivities_count" = get_collectivities_count_in_ddfips("ddfips".*)
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
      SET     "communes_count"       = get_communes_count_in_epcis("epcis".*),
              "collectivities_count" = get_collectivities_count_in_epcis("epcis".*)
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
      SET     "collectivities_count" = get_collectivities_count_in_communes("communes".*)
      WHERE   "communes"."siren_epci" IN (NEW."siren", OLD."siren");

      UPDATE  "departements"
      SET     "epcis_count"          = get_epcis_count_in_departements("departements".*),
              "collectivities_count" = get_collectivities_count_in_departements("departements".*)
      WHERE   "departements"."code_departement" IN (NEW."code_departement", OLD."code_departement")
        OR    "departements"."code_departement" IN (
                SELECT "communes"."code_departement"
                FROM   "communes"
                WHERE  "communes"."siren_epci" IN (NEW."siren", OLD."siren")
              );

      UPDATE  "regions"
      SET     "epcis_count"          = get_epcis_count_in_regions("regions".*),
              "collectivities_count" = get_collectivities_count_in_regions("regions".*)
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
      SET     "collectivities_count" = get_collectivities_count_in_ddfips("ddfips".*)
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
    SET     "communes_count" = get_communes_count_in_offices("offices".*)
    WHERE   "offices"."id" IN (NEW."office_id", OLD."office_id");

    UPDATE  "communes"
    SET     "offices_count" = get_offices_count_in_communes("communes".*)
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
    SET     "users_count" = get_users_count_in_offices("offices".*)
    WHERE   "offices"."id" IN (NEW."office_id", OLD."office_id");

    UPDATE  "users"
    SET     "offices_count" = get_offices_count_in_users("users".*)
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

    IF (TG_OP = 'INSERT')
    OR (TG_OP = 'DELETE')
    OR (TG_OP = 'UPDATE' AND NEW."ddfip_id" <> OLD."ddfip_id")
    THEN

      UPDATE  "ddfips"
      SET     "offices_count" = get_offices_count_in_ddfips("ddfips".*)
      WHERE   "ddfips"."id" IN (NEW."ddfip_id", OLD."ddfip_id");

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
      SET    "users_count" = get_users_count_in_publishers("publishers".*)
      WHERE  (NEW."organization_type" = 'Publisher' AND "publishers"."id" = NEW."organization_id")
        OR   (OLD."organization_type" = 'Publisher' AND "publishers"."id" = OLD."organization_id");

      UPDATE "collectivities"
      SET    "users_count" = get_users_count_in_collectivities("collectivities".*)
      WHERE  (NEW."organization_type" = 'Collectivity' AND "collectivities"."id" = NEW."organization_id")
        OR   (OLD."organization_type" = 'Collectivity' AND "collectivities"."id" = OLD."organization_id");

      UPDATE "ddfips"
      SET    "users_count" = get_users_count_in_ddfips("ddfips".*)
      WHERE  (NEW."organization_type" = 'DDFIP' AND "ddfips"."id" = NEW."organization_id")
        OR   (OLD."organization_type" = 'DDFIP' AND "ddfips"."id" = OLD."organization_id");

      UPDATE "offices"
      SET    "users_count" = get_users_count_in_offices("offices".*)
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
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
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
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


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
-- Name: epcis epcis_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.epcis
    ADD CONSTRAINT epcis_pkey PRIMARY KEY (id);


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
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


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
-- Name: index_epcis_on_code_departement; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_epcis_on_code_departement ON public.epcis USING btree (code_departement);


--
-- Name: index_epcis_on_siren; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_epcis_on_siren ON public.epcis USING btree (siren);


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
-- Name: index_offices_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_offices_on_discarded_at ON public.offices USING btree (discarded_at);


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

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


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
-- Name: users trigger_users_changes; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_users_changes AFTER INSERT OR DELETE OR UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.trigger_users_changes();


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
-- Name: office_users fk_rails_34d1da443b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.office_users
    ADD CONSTRAINT fk_rails_34d1da443b FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


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
-- Name: collectivities fk_rails_8f20c81d41; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.collectivities
    ADD CONSTRAINT fk_rails_8f20c81d41 FOREIGN KEY (publisher_id) REFERENCES public.publishers(id);


--
-- Name: office_communes fk_rails_b43ade12e1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.office_communes
    ADD CONSTRAINT fk_rails_b43ade12e1 FOREIGN KEY (office_id) REFERENCES public.offices(id) ON DELETE CASCADE;


--
-- Name: communes fk_rails_ca34c89446; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.communes
    ADD CONSTRAINT fk_rails_ca34c89446 FOREIGN KEY (code_departement) REFERENCES public.departements(code_departement);


--
-- Name: ddfips fk_rails_da3790c57d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ddfips
    ADD CONSTRAINT fk_rails_da3790c57d FOREIGN KEY (code_departement) REFERENCES public.departements(code_departement);


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
('20230412064850');

