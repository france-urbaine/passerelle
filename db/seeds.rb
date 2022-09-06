# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

require "csv"

# Import regions
# ----------------------------------------------------------------------------
regions_path = Rails.root.join("db/regions.csv")
regions_data = CSV.open(regions_path, "r", headers: true, col_sep: ";").map(&:to_h)

Region.upsert_all(regions_data, unique_by: %i[code_region])

# Import departements
# ----------------------------------------------------------------------------
departements_path = Rails.root.join("db/departements.csv")
departements_data = CSV.open(departements_path, "r", headers: true, col_sep: ";").map(&:to_h)

Departement.upsert_all(departements_data, unique_by: %i[code_departement])

# Import EPCI & communes
# ----------------------------------------------------------------------------
ImportEpcisJob.perform_now("https://www.insee.fr/fr/statistiques/fichier/2510634/Intercommunalite_Metropole_au_01-01-2022.zip")
ImportCommunesJob.perform_now("https://www.insee.fr/fr/statistiques/fichier/2028028/table-appartenance-geo-communes-22.zip")

# Create organizations
# ----------------------------------------------------------------------------
DDFIP.insert_all([
  { code_departement: "13", name: "DDFIP des Bouches-du-Rhône" },
  { code_departement: "18", name: "DDFIP du Cher" },
  { code_departement: "51", name: "DDFIP de la Marne" },
  { code_departement: "59", name: "DDFIP du Nord" },
  { code_departement: "64", name: "DDFIP des Pyrénées-Atlantiques" },
  { code_departement: "91", name: "DDFIP de l'Essonne" }
])

Publisher.insert_all([
  { name: "Fiscalité & Territoire", siren: "511022394", email: "contact@fiscalite-territoire.fr" }
])

fiscalite_territoire = Publisher.find_by(name: "Fiscalité & Territoire")

[
  "CA du Pays Basque",
  "Métropole Européenne de Lille",
  "Métropole d'Aix-Marseille-Provence"
].map do |epci_name|
  epci = EPCI.find_by!(name: epci_name)

  Collectivity.where(siren: epci.siren).first_or_create(
    name:             epci_name,
    territory:        epci,
    publisher:        fiscalite_territoire,
    approved_at:      Time.current
  )
end

# Users organizations
# ----------------------------------------------------------------------------
pays_basque = Collectivity.find_by!(name: "CA du Pays Basque")
ddfip64     = DDFIP.find_by(name: "DDFIP des Pyrénées-Atlantiques")

User.insert_all([
  {
    email:              "mdebomy@fiscalite-territoire.fr",
    last_name:          "Debomy",
    first_name:         "Marc",
    organization_type:  "Publisher",
    organization_id:    fiscalite_territoire.id,
    organization_admin: true,
    super_admin:        true
  }, {
    email:              "ssavater@fiscalite-territoire.fr",
    last_name:          "Savater",
    first_name:         "Sebastien",
    organization_type:  "Publisher",
    organization_id:    fiscalite_territoire.id,
    organization_admin: true,
    super_admin:        true
  },
  {
    email:              "admin@pays-basque.example.org",
    first_name:         "Admin",
    last_name:          "Pays Basque",
    organization_type:  "Collectivity",
    organization_id:    pays_basque.id,
    organization_admin: true,
    super_admin:        false
  },
  {
    email:              "user@pays-basque.example.org",
    first_name:         "User",
    last_name:          "Pays Basque",
    organization_type:  "Collectivity",
    organization_id:    pays_basque.id,
    organization_admin: false,
    super_admin:        false
  },
  {
    email:              "admin@ddfip-64.example.org",
    first_name:         "Admin",
    last_name:          "DDFIP 64",
    organization_type:  "DDFIP",
    organization_id:    ddfip64.id,
    organization_admin: true,
    super_admin:        false
  },
  {
    email:              "pelp@ddfip-64.example.org",
    first_name:         "PELP",
    last_name:          "DDFIP 64",
    organization_type:  "DDFIP",
    organization_id:    ddfip64.id,
    organization_admin: false,
    super_admin:        false
  },
  {
    email:              "bayonne@ddfip-64.example.org",
    first_name:         "Bayonne",
    last_name:          "DDFIP 64",
    organization_type:  "DDFIP",
    organization_id:    ddfip64.id,
    organization_admin: false,
    super_admin:        false
  }
])
