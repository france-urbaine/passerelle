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

# Import EPCIs
# ----------------------------------------------------------------------------
ImportEpcisJob.perform_now("https://www.insee.fr/fr/statistiques/fichier/2510634/Intercommunalite_Metropole_au_01-01-2021.zip")
ImportEpcisDepartementsJob.perform_now("https://www.insee.fr/fr/statistiques/fichier/2510634/Intercommunalite_Metropole_au_01-01-2021.zip")

# Import communes
# ----------------------------------------------------------------------------
ImportCommunesJob.perform_now("https://www.insee.fr/fr/statistiques/fichier/2028028/table-appartenance-geo-communes-21.zip")
