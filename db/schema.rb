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

ActiveRecord::Schema[7.0].define(version: 2022_06_02_130101) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "unaccent"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
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
    t.index ["code_region"], name: "index_regions_on_code_region", unique: true
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
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["inviter_id"], name: "index_users_on_inviter_id"
    t.index ["organization_type", "organization_id"], name: "index_users_on_organization"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

end
