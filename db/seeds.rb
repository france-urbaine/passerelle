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
puts "Seed regions"

regions_path = Rails.root.join("db/regions.csv")
regions_data = CSV.open(regions_path, "r", headers: true, col_sep: ";").map(&:to_h)

Region.upsert_all(regions_data, unique_by: %i[code_region])

# Import departements
# ----------------------------------------------------------------------------
puts "Seed departements"

departements_path = Rails.root.join("db/departements.csv")
departements_data = CSV.open(departements_path, "r", headers: true, col_sep: ";").map(&:to_h)

Departement.upsert_all(departements_data, unique_by: %i[code_departement])

# Import EPCI & communes
# ----------------------------------------------------------------------------
puts "Seed epcis"
ImportEpcisJob.perform_now("https://www.insee.fr/fr/statistiques/fichier/2510634/Intercommunalite_Metropole_au_01-01-2022.zip")

puts "Seed communes"
ImportCommunesJob.perform_now("https://www.insee.fr/fr/statistiques/fichier/2028028/table-appartenance-geo-communes-22.zip")

# Import ddfips
# ----------------------------------------------------------------------------
puts "Seed ddfips"

DDFIP.insert_all([
  { code_departement: "13", name: "DDFIP des Bouches-du-Rhône" },
  { code_departement: "18", name: "DDFIP du Cher" },
  { code_departement: "51", name: "DDFIP de la Marne" },
  { code_departement: "59", name: "DDFIP du Nord" },
  { code_departement: "64", name: "DDFIP des Pyrénées-Atlantiques" },
  { code_departement: "91", name: "DDFIP de l'Essonne" }
])

# Import publishers
# ----------------------------------------------------------------------------
puts "Seed publishers"

Publisher.insert_all([
  { siren: "301463253", name: "France Urbaine",                   email: "franceurbaine@franceurbaine.org" },
  { siren: "511022394", name: "Fiscalité & Territoire",           email: "contact@fiscalite-territoire.fr" },
  { siren: "335273371", name: "FININDEV",                         email: "" },
  { siren: "385365713", name: "INETUM",                           email: "" },
  { siren: "383884574", name: "A6 CONSEIL METHODES ORGANISATION", email: "" }
])

# Import collectivities
# ----------------------------------------------------------------------------
puts "Seed collectivities"

@publishers = Publisher.pluck(:name, :id).to_h

def build_collectivity(data = {})
  data[:publisher_id] = @publishers[data.delete(:publisher)]

  case data
  in commune: String
    territory = Commune.find_by!(name: data.delete(:commune))
    data[:territory_type] = "Commune"
    data[:territory_id]   = territory.id
    data[:name]           = territory.qualified_name
  in epci: String
    territory = EPCI.find_by!(name: data.delete(:epci))
    data[:territory_type] = "EPCI"
    data[:territory_id]   = territory.id
    data[:name]           = territory.name
  end

  data
end

Collectivity.insert_all([
  build_collectivity(publisher: "Fiscalité & Territoire", siren: "200067106", epci:    "CA du Pays Basque"),
  build_collectivity(publisher: "Fiscalité & Territoire", siren: "200093201", epci:    "Métropole Européenne de Lille"),
  build_collectivity(publisher: "Fiscalité & Territoire", siren: "200054807", epci:    "Métropole d'Aix-Marseille-Provence"),
  build_collectivity(publisher: "Fiscalité & Territoire", siren: "217500016", commune: "Paris")
])

# Import users
# ----------------------------------------------------------------------------
puts "Seed users"

collectivities = Collectivity.all.index_by(&:name)
publishers     = Publisher.all.index_by(&:name)
ddfips         = DDFIP.all.index_by(&:name)

def build_user(data = {})
  data[:first_name] ||= Faker::Name.first_name
  data[:last_name]  ||= Faker::Name.last_name

  data[:name]              = data.values_at(:first_name, :last_name).join(" ").strip
  data[:organization_type] = data[:organization].class.name
  data[:organization_id]   = data[:organization].id
  data.delete(:organization)

  data[:confirmed_at] = Time.current if data.delete(:confirmed)

  data.reverse_merge(
    confirmed_at:       nil,
    organization_admin: false,
    super_admin:        false
  )
end

User.insert_all([
  build_user(email: "random@fu.example.org",            organization: publishers["France Urbaine"],         organization_admin: true, super_admin: true, confirmed: true),
  build_user(email: "random@ft.example.org",            organization: publishers["Fiscalité & Territoire"], organization_admin: true, super_admin: true, confirmed: true),
  build_user(email: "admin@pays-basque.example.org",    organization: collectivities["CA du Pays Basque"],  organization_admin: true),
  build_user(email: "user@pays-basque.example.org",     organization: collectivities["CA du Pays Basque"]),
  build_user(email: "admin@ddfip-64.example.org",       organization: ddfips["DDFIP des Pyrénées-Atlantiques"], organization_admin: true),
  build_user(email: "pelp@ddfip-64.example.org",        organization: ddfips["DDFIP des Pyrénées-Atlantiques"]),
  build_user(email: "sip.bayonne@ddfip-64.example.org", organization: ddfips["DDFIP des Pyrénées-Atlantiques"]),
  build_user(email: "sip.pau@ddfip-64.example.org",     organization: ddfips["DDFIP des Pyrénées-Atlantiques"])
])

# Import services
# ----------------------------------------------------------------------------
puts "Seed services"

ddfips = DDFIP.pluck(:name, :id).to_h

Service.insert_all([
  { ddfip_id: ddfips["DDFIP des Pyrénées-Atlantiques"], name: "PELH de Bayonne",  action: "evaluation_hab" },
  { ddfip_id: ddfips["DDFIP des Pyrénées-Atlantiques"], name: "PELP de Bayonne",  action: "evaluation_eco" },
  { ddfip_id: ddfips["DDFIP des Pyrénées-Atlantiques"], name: "SIP de Bayonne",   action: "occupation_hab" },
  { ddfip_id: ddfips["DDFIP des Pyrénées-Atlantiques"], name: "SIP de Pau",       action: "occupation_hab" },
  { ddfip_id: ddfips["DDFIP de l'Essonne"],             name: "SIP de l'Essonne", action: "occupation_hab" }
])

services = Service.pluck(:name, :id).to_h
users    = User.where(organization_type: "DDFIP").pluck(:email, :id).to_h

UserService.insert_all([
  { service_id: services["PELP de Bayonne"], user_id: users["admin@ddfip-64.example.org"] },
  { service_id: services["PELH de Bayonne"], user_id: users["admin@ddfip-64.example.org"] },
  { service_id: services["SIP de Bayonne"],  user_id: users["admin@ddfip-64.example.org"] },
  { service_id: services["PELP de Bayonne"], user_id: users["pelp@ddfip-64.example.org"] },
  { service_id: services["SIP de Bayonne"],  user_id: users["sip.bayonne@ddfip-64.example.org"] }
])

bayonne_codes_insee = EPCI.find_by!(name: "CA du Pays Basque").communes.pluck(:code_insee)
pau_codes_insee     = EPCI.find_by!(name: "CA Pau Béarn Pyrénées").communes.pluck(:code_insee)

ServiceCommune.insert_all(bayonne_codes_insee.map { |code| { service_id: services["PELP de Bayonne"], code_insee: code } })
ServiceCommune.insert_all(bayonne_codes_insee.map { |code| { service_id: services["PELH de Bayonne"], code_insee: code } })
ServiceCommune.insert_all(bayonne_codes_insee.map { |code| { service_id: services["SIP de Bayonne"], code_insee: code } })
ServiceCommune.insert_all(pau_codes_insee.map { |code| { service_id: services["SIP de Pau"], code_insee: code } })
