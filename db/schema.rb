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

ActiveRecord::Schema[7.0].define(version: 2022_04_09_140409) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "collectivities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "territory_type", null: false
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
    t.index ["discarded_at"], name: "index_collectivities_on_discarded_at"
    t.index ["name"], name: "index_collectivities_on_name", unique: true, where: "(discarded_at IS NULL)"
    t.index ["publisher_id"], name: "index_collectivities_on_publisher_id"
    t.index ["siren"], name: "index_collectivities_on_siren", unique: true, where: "(discarded_at IS NULL)"
    t.index ["territory_type", "territory_id"], name: "index_collectivities_on_territory"
  end

  create_table "ddfips", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "code_departement", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["code_departement"], name: "index_ddfips_on_code_departement"
    t.index ["discarded_at"], name: "index_ddfips_on_discarded_at"
    t.index ["name"], name: "index_ddfips_on_name", unique: true, where: "(discarded_at IS NULL)"
  end

  create_table "publishers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "siren", null: false
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_publishers_on_discarded_at"
    t.index ["name"], name: "index_publishers_on_name", unique: true, where: "(discarded_at IS NULL)"
    t.index ["siren"], name: "index_publishers_on_siren", unique: true, where: "(discarded_at IS NULL)"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "organization_type", null: false
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
