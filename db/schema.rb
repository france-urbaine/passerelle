# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_09_01_135804) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "unaccent"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "action", ["evaluation_hab", "evaluation_eco", "occupation_hab", "occupation_eco"]
  create_enum "epci_nature", ["ME", "CC", "CA", "CU"]
  create_enum "organization_type", ["Collectivity", "Publisher", "DDFIP"]
  create_enum "territory_type", ["Commune", "EPCI", "Departement", "Region"]

  create_table "collectivities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.enum "territory_type", null: false, enum_type: "territory_type"
    t.uuid "territory_id", null: false
    t.uuid "publisher_id"
    t.string "name", null: false
    t.string "siren", null: false
    t.string "contact_first_name"
    t.string "contact_last_name"
    t.string "contact_email"
    t.string "contact_phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "approved_at"
    t.datetime "disapproved_at"
    t.datetime "desactivated_at"
    t.datetime "discarded_at"
    t.integer "users_count", default: 0, null: false
    t.index ["discarded_at"], name: "index_collectivities_on_discarded_at"
    t.index ["name"], name: "index_collectivities_on_name", unique: true, where: "(discarded_at IS NULL)"
    t.index ["publisher_id"], name: "index_collectivities_on_publisher_id"
    t.index ["siren"], name: "index_collectivities_on_siren", unique: true, where: "(discarded_at IS NULL)"
    t.index ["territory_type", "territory_id"], name: "index_collectivities_on_territory"
  end

  create_table "communes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "code_insee", null: false
    t.string "code_departement", null: false
    t.string "siren_epci"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "collectivities_count", default: 0, null: false
    t.string "qualified_name"
    t.integer "services_count", default: 0, null: false
    t.index ["code_departement"], name: "index_communes_on_code_departement"
    t.index ["code_insee"], name: "index_communes_on_code_insee", unique: true
    t.index ["siren_epci"], name: "index_communes_on_siren_epci"
  end

  create_table "ddfips", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "code_departement", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.integer "users_count", default: 0, null: false
    t.integer "collectivities_count", default: 0, null: false
    t.integer "services_count", default: 0, null: false
    t.index ["code_departement"], name: "index_ddfips_on_code_departement"
    t.index ["discarded_at"], name: "index_ddfips_on_discarded_at"
    t.index ["name"], name: "index_ddfips_on_name", unique: true, where: "(discarded_at IS NULL)"
  end

  create_table "departements", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "code_departement", null: false
    t.string "code_region", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "epcis_count", default: 0, null: false
    t.integer "communes_count", default: 0, null: false
    t.integer "ddfips_count", default: 0, null: false
    t.integer "collectivities_count", default: 0, null: false
    t.string "qualified_name"
    t.index ["code_departement"], name: "index_departements_on_code_departement", unique: true
    t.index ["code_region"], name: "index_departements_on_code_region"
  end

  create_table "epcis", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "siren", null: false
    t.string "code_departement"
    t.enum "nature", enum_type: "epci_nature"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "communes_count", default: 0, null: false
    t.integer "collectivities_count", default: 0, null: false
    t.index ["code_departement"], name: "index_epcis_on_code_departement"
    t.index ["siren"], name: "index_epcis_on_siren", unique: true
  end

  create_table "publishers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "siren", null: false
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.integer "users_count", default: 0, null: false
    t.integer "collectivities_count", default: 0, null: false
    t.index ["discarded_at"], name: "index_publishers_on_discarded_at"
    t.index ["name"], name: "index_publishers_on_name", unique: true, where: "(discarded_at IS NULL)"
    t.index ["siren"], name: "index_publishers_on_siren", unique: true, where: "(discarded_at IS NULL)"
  end

  create_table "regions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "code_region", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "departements_count", default: 0, null: false
    t.integer "epcis_count", default: 0, null: false
    t.integer "communes_count", default: 0, null: false
    t.integer "ddfips_count", default: 0, null: false
    t.integer "collectivities_count", default: 0, null: false
    t.string "qualified_name"
    t.index ["code_region"], name: "index_regions_on_code_region", unique: true
  end

  create_table "service_communes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "service_id", null: false
    t.string "code_insee", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code_insee"], name: "index_service_communes_on_code_insee"
    t.index ["service_id", "code_insee"], name: "index_service_communes_on_service_id_and_code_insee", unique: true
    t.index ["service_id"], name: "index_service_communes_on_service_id"
  end

  create_table "services", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "ddfip_id"
    t.string "name", null: false
    t.enum "action", null: false, enum_type: "action"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.integer "users_count", default: 0, null: false
    t.integer "communes_count", default: 0, null: false
    t.index ["ddfip_id"], name: "index_services_on_ddfip_id"
    t.index ["discarded_at"], name: "index_services_on_discarded_at"
  end

  create_table "user_services", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "service_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["service_id", "user_id"], name: "index_user_services_on_service_id_and_user_id", unique: true
    t.index ["service_id"], name: "index_user_services_on_service_id"
    t.index ["user_id"], name: "index_user_services_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.enum "organization_type", null: false, enum_type: "organization_type"
    t.uuid "organization_id", null: false
    t.uuid "inviter_id"
    t.string "first_name", default: "", null: false
    t.string "last_name", default: "", null: false
    t.boolean "super_admin", default: false, null: false
    t.boolean "organization_admin", default: false, null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "invited_at"
    t.integer "services_count", default: 0, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["inviter_id"], name: "index_users_on_inviter_id"
    t.index ["organization_type", "organization_id"], name: "index_users_on_organization"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "service_communes", "services", on_delete: :cascade
  add_foreign_key "user_services", "services", on_delete: :cascade
  add_foreign_key "user_services", "users", on_delete: :cascade
  create_function :get_collectivities_users_count, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.get_collectivities_users_count(collectivities collectivities)
       RETURNS integer
       LANGUAGE plpgsql
      AS $function$
        BEGIN
          RETURN (
            SELECT COUNT(*)
            FROM   "users"
            WHERE  "users"."organization_type" = 'Collectivity'
              AND  "users"."organization_id"   = collectivities."id"
          );
        END;
      $function$
  SQL
  create_function :get_communes_collectivities_count, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.get_communes_collectivities_count(communes communes)
       RETURNS integer
       LANGUAGE plpgsql
      AS $function$
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
      $function$
  SQL
  create_function :get_ddfips_collectivities_count, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.get_ddfips_collectivities_count(ddfips ddfips)
       RETURNS integer
       LANGUAGE plpgsql
      AS $function$
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
      $function$
  SQL
  create_function :get_ddfips_users_count, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.get_ddfips_users_count(ddfips ddfips)
       RETURNS integer
       LANGUAGE plpgsql
      AS $function$
        BEGIN
          RETURN (
            SELECT COUNT(*)
            FROM   "users"
            WHERE  "users"."organization_type" = 'DDFIP'
              AND  "users"."organization_id"   = ddfips."id"
          );
        END;
      $function$
  SQL
  create_function :get_departements_collectivities_count, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.get_departements_collectivities_count(departements departements)
       RETURNS integer
       LANGUAGE plpgsql
      AS $function$
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
      $function$
  SQL
  create_function :get_departements_communes_count, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.get_departements_communes_count(departements departements)
       RETURNS integer
       LANGUAGE plpgsql
      AS $function$
        BEGIN
          RETURN (
            SELECT COUNT(*)
            FROM   "communes"
            WHERE  "communes"."code_departement" = departements."code_departement"
          );
        END;
      $function$
  SQL
  create_function :get_departements_ddfips_count, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.get_departements_ddfips_count(departements departements)
       RETURNS integer
       LANGUAGE plpgsql
      AS $function$
        BEGIN
          RETURN (
            SELECT COUNT(*)
            FROM   "ddfips"
            WHERE  "ddfips"."code_departement" = departements."code_departement"
          );
        END;
      $function$
  SQL
  create_function :get_departements_epcis_count, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.get_departements_epcis_count(departements departements)
       RETURNS integer
       LANGUAGE plpgsql
      AS $function$
        BEGIN
          RETURN (
            SELECT COUNT(*)
            FROM   "epcis"
            WHERE  "epcis"."code_departement" = departements."code_departement"
          );
        END;
      $function$
  SQL
  create_function :get_epcis_collectivities_count, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.get_epcis_collectivities_count(epcis epcis)
       RETURNS integer
       LANGUAGE plpgsql
      AS $function$
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
      $function$
  SQL
  create_function :get_epcis_communes_count, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.get_epcis_communes_count(epcis epcis)
       RETURNS integer
       LANGUAGE plpgsql
      AS $function$
        BEGIN
          RETURN (
            SELECT COUNT(*)
            FROM   "communes"
            WHERE  "communes"."siren_epci" = epcis."siren"
          );
        END;
      $function$
  SQL
  create_function :get_publishers_collectivities_count, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.get_publishers_collectivities_count(publishers publishers)
       RETURNS integer
       LANGUAGE plpgsql
      AS $function$
        BEGIN
          RETURN (
            SELECT COUNT(*)
            FROM   "collectivities"
            WHERE  "collectivities"."discarded_at" IS NULL
              AND  "collectivities"."publisher_id" = publishers."id"
          );
        END;
      $function$
  SQL
  create_function :get_publishers_users_count, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.get_publishers_users_count(publishers publishers)
       RETURNS integer
       LANGUAGE plpgsql
      AS $function$
        BEGIN
          RETURN (
            SELECT COUNT(*)
            FROM   "users"
            WHERE  "users"."organization_type" = 'Publisher'
              AND  "users"."organization_id"   = publishers."id"
          );
        END;
      $function$
  SQL
  create_function :get_regions_collectivities_count, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.get_regions_collectivities_count(regions regions)
       RETURNS integer
       LANGUAGE plpgsql
      AS $function$
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
      $function$
  SQL
  create_function :get_regions_communes_count, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.get_regions_communes_count(regions regions)
       RETURNS integer
       LANGUAGE plpgsql
      AS $function$
        BEGIN
          RETURN (
            SELECT     COUNT(*)
            FROM       "communes"
            INNER JOIN "departements" ON "departements"."code_departement" = "communes"."code_departement"
            WHERE      "departements"."code_region" = regions."code_region"
          );
        END;
      $function$
  SQL
  create_function :get_regions_ddfips_count, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.get_regions_ddfips_count(regions regions)
       RETURNS integer
       LANGUAGE plpgsql
      AS $function$
        BEGIN
          RETURN (
            SELECT     COUNT(*)
            FROM       "ddfips"
            INNER JOIN "departements" ON "departements"."code_departement" = "ddfips"."code_departement"
            WHERE      "departements"."code_region" = regions."code_region"
          );
        END;
      $function$
  SQL
  create_function :get_regions_departements_count, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.get_regions_departements_count(regions regions)
       RETURNS integer
       LANGUAGE plpgsql
      AS $function$
        BEGIN
          RETURN (
            SELECT COUNT(*)
            FROM   "departements"
            WHERE  "departements"."code_region" = regions."code_region"
          );
        END;
      $function$
  SQL
  create_function :get_regions_epcis_count, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.get_regions_epcis_count(regions regions)
       RETURNS integer
       LANGUAGE plpgsql
      AS $function$
        BEGIN
          RETURN (
            SELECT     COUNT(*)
            FROM       "epcis"
            INNER JOIN "departements" ON "departements"."code_departement" = "epcis"."code_departement"
            WHERE      "departements"."code_region" = regions."code_region"
          );
        END;
      $function$
  SQL
  create_function :reset_all_collectivities_counters, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.reset_all_collectivities_counters()
       RETURNS integer
       LANGUAGE plpgsql
      AS $function$
        DECLARE
          affected_rows integer;
        BEGIN
          UPDATE "collectivities"
          SET    "users_count" = get_collectivities_users_count("collectivities".*);

          GET DIAGNOSTICS affected_rows = ROW_COUNT;
          RAISE NOTICE 'UPDATE %', affected_rows;

          RETURN affected_rows;
        END;
      $function$
  SQL
  create_function :reset_all_communes_counters, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.reset_all_communes_counters()
       RETURNS integer
       LANGUAGE plpgsql
      AS $function$
        DECLARE
          affected_rows integer;
        BEGIN
          UPDATE "communes"
          SET    "collectivities_count" = get_communes_collectivities_count("communes".*);

          GET DIAGNOSTICS affected_rows = ROW_COUNT;
          RAISE NOTICE 'UPDATE %', affected_rows;

          RETURN affected_rows;
        END;
      $function$
  SQL
  create_function :reset_all_ddfips_counters, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.reset_all_ddfips_counters()
       RETURNS integer
       LANGUAGE plpgsql
      AS $function$
        DECLARE
          affected_rows integer;
        BEGIN
          UPDATE "ddfips"
          SET    "users_count"          = get_ddfips_users_count("ddfips".*),
                 "collectivities_count" = get_ddfips_collectivities_count("ddfips".*);

          GET DIAGNOSTICS affected_rows = ROW_COUNT;
          RAISE NOTICE 'UPDATE %', affected_rows;

          RETURN affected_rows;
        END;
      $function$
  SQL
  create_function :reset_all_departements_counters, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.reset_all_departements_counters()
       RETURNS integer
       LANGUAGE plpgsql
      AS $function$
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
      $function$
  SQL
  create_function :reset_all_epcis_counters, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.reset_all_epcis_counters()
       RETURNS integer
       LANGUAGE plpgsql
      AS $function$
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
      $function$
  SQL
  create_function :reset_all_publishers_counters, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.reset_all_publishers_counters()
       RETURNS integer
       LANGUAGE plpgsql
      AS $function$
        DECLARE
          affected_rows integer;
        BEGIN
          UPDATE "publishers"
          SET    "users_count"          = get_publishers_users_count("publishers".*),
                 "collectivities_count" = get_publishers_collectivities_count("publishers".*);

          GET DIAGNOSTICS affected_rows = ROW_COUNT;
          RAISE NOTICE 'UPDATE %', affected_rows;

          RETURN affected_rows;
        END;
      $function$
  SQL
  create_function :reset_all_regions_counters, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.reset_all_regions_counters()
       RETURNS integer
       LANGUAGE plpgsql
      AS $function$
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
      $function$
  SQL
  create_function :trigger_collectivities_changes, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.trigger_collectivities_changes()
       RETURNS trigger
       LANGUAGE plpgsql
      AS $function$
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
      $function$
  SQL
  create_function :trigger_communes_changes, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.trigger_communes_changes()
       RETURNS trigger
       LANGUAGE plpgsql
      AS $function$
        BEGIN
          -- Reset self communes#collectivities_count
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
      $function$
  SQL
  create_function :trigger_ddfips_changes, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.trigger_ddfips_changes()
       RETURNS trigger
       LANGUAGE plpgsql
      AS $function$
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
      $function$
  SQL
  create_function :trigger_departements_changes, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.trigger_departements_changes()
       RETURNS trigger
       LANGUAGE plpgsql
      AS $function$
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
      $function$
  SQL
  create_function :trigger_epcis_changes, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.trigger_epcis_changes()
       RETURNS trigger
       LANGUAGE plpgsql
      AS $function$
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
      $function$
  SQL
  create_function :trigger_users_changes, sql_definition: <<-'SQL'
      CREATE OR REPLACE FUNCTION public.trigger_users_changes()
       RETURNS trigger
       LANGUAGE plpgsql
      AS $function$
        BEGIN
          -- Reset all users_count
          -- * on creation
          -- * on deletion
          -- * when organization_id changed

          IF (TG_OP = 'INSERT')
          OR (TG_OP = 'DELETE')
          OR (TG_OP = 'UPDATE' AND NEW."organization_id" <> OLD."organization_id")
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

          END IF;

          -- result is ignored since this is an AFTER trigger
          RETURN NULL;
        END;
      $function$
  SQL


  create_trigger :trigger_collectivities_changes, sql_definition: <<-SQL
      CREATE TRIGGER trigger_collectivities_changes AFTER INSERT OR DELETE OR UPDATE ON public.collectivities FOR EACH ROW EXECUTE FUNCTION trigger_collectivities_changes()
  SQL
  create_trigger :trigger_communes_changes, sql_definition: <<-SQL
      CREATE TRIGGER trigger_communes_changes AFTER INSERT OR DELETE OR UPDATE ON public.communes FOR EACH ROW EXECUTE FUNCTION trigger_communes_changes()
  SQL
  create_trigger :trigger_ddfips_changes, sql_definition: <<-SQL
      CREATE TRIGGER trigger_ddfips_changes AFTER INSERT OR DELETE OR UPDATE ON public.ddfips FOR EACH ROW EXECUTE FUNCTION trigger_ddfips_changes()
  SQL
  create_trigger :trigger_departements_changes, sql_definition: <<-SQL
      CREATE TRIGGER trigger_departements_changes AFTER INSERT OR DELETE OR UPDATE ON public.departements FOR EACH ROW EXECUTE FUNCTION trigger_departements_changes()
  SQL
  create_trigger :trigger_epcis_changes, sql_definition: <<-SQL
      CREATE TRIGGER trigger_epcis_changes AFTER INSERT OR DELETE OR UPDATE ON public.epcis FOR EACH ROW EXECUTE FUNCTION trigger_epcis_changes()
  SQL
  create_trigger :trigger_users_changes, sql_definition: <<-SQL
      CREATE TRIGGER trigger_users_changes AFTER INSERT OR DELETE OR UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION trigger_users_changes()
  SQL
end
