# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

LOG_PREFIX = "\e[34m[ db/seed ]\e[0m"

def log(message)
  puts "#{LOG_PREFIX} #{message}"
end

def gets
  print "#{LOG_PREFIX} > "
  $stdin.gets.strip
end

# Import EPCIs and communes from a remote source
# ----------------------------------------------------------------------------
if ENV["SEED_ALL_EPCIS_AND_COMMUNES"] == "true"
  TerritoriesUpdate.new.assign_default_urls.perform_now
  exit
end

# Seed one user through interactive command
# ----------------------------------------------------------------------------
if ENV["SEED_INTERACTIVE_USER"] == "true"
  log "Please enter your email:"
  email = gets

  log "Please enter your first name (or press enter to generate a random value):"
  first_name = gets
  first_name = Faker::Name.first_name if first_name.blank?

  log "Please enter your last name (or press enter to generate a random value):"
  last_name = gets
  last_name = Faker::Name.last_name if last_name.blank?

  user = Publisher
    .create_or_find_by(siren: "511022394", name: "Fiscalité & Territoire", &:skip_uniqueness_validation!)
    .users.create!(
      email:              email,
      first_name:         first_name,
      last_name:          last_name,
      organization_admin: true,
      super_admin:        true,
      password:           Devise.friendly_token
    )

  log ""
  log "Your user has been created !"

  url = Rails.application.routes.url_helpers.user_registration_url(
    host:  "http://localhost:3000",
    token: user.confirmation_token
  )

  log ""
  log "Start a server with `bin/dev` command"
  log "Then, click on the link below to complete your registration:"
  log "  #{url}"
  log ""
  exit
end

# CSV parser
# ----------------------------------------------------------------------------
def parse_csv(path)
  require "csv"
  path = Rails.root.join(path)
  CSV.open(path, "r", headers: true, col_sep: ";").map(&:to_h)
end

# Import territories
# ----------------------------------------------------------------------------
log "Seed regions"

Region.upsert_all(
  parse_csv("db/regions.csv"),
  unique_by: %i[code_region]
)

log "Seed departements"

Departement.upsert_all(
  parse_csv("db/departements.csv"),
  unique_by: %i[code_departement]
)

log "Seed EPCIs"

EPCI.upsert_all(
  parse_csv("db/epcis.csv"),
  unique_by: %i[siren]
)

log "Seed communes"

Commune.upsert_all(
  parse_csv("db/communes.csv"),
  unique_by: %i[code_insee]
)

# Import ddfips
# ----------------------------------------------------------------------------
log "Seed DDFIP"

DDFIP.insert_all([
  { code_departement: "13", name: "DDFIP des Bouches-du-Rhône" },
  { code_departement: "18", name: "DDFIP du Cher" },
  { code_departement: "31", name: "DRFIP Occitanie et département de la Haute-Garonne" },
  { code_departement: "33", name: "DDFIP de la Gironde" },
  { code_departement: "51", name: "DDFIP de la Marne" },
  { code_departement: "57", name: "DDFIP de la Moselle" },
  { code_departement: "59", name: "DDFIP du Nord" },
  { code_departement: "64", name: "DDFIP des Pyrénées-Atlantiques" },
  { code_departement: "69", name: "DDFIP du Rhône" },
  { code_departement: "75", name: "DDFIP - Paris" },
  { code_departement: "91", name: "DDFIP de l'Essonne" }
])

# Import publishers
# ----------------------------------------------------------------------------
log "Seed publishers"

Publisher.insert_all([
  { siren: "301463253", name: "France Urbaine",         contact_email: "franceurbaine@franceurbaine.org" },
  { siren: "511022394", name: "Fiscalité & Territoire", contact_email: "contact@fiscalite-territoire.fr" },
  { siren: "335273371", name: "FININDEV",               contact_email: "contact@finindev.com" },
  { siren: "385365713", name: "INETUM",                 contact_email: "contact@inetum.com" },
  { siren: "383884574", name: "A6CMO",                  contact_email: "" }
])

# Import collectivities
# ----------------------------------------------------------------------------
log "Seed collectivities"

def parse_collectivities(data)
  publishers = Publisher.pluck(:name, :id).to_h

  data.map do |hash|
    publisher = publishers[hash.delete(:publisher)]
    territory =
      case hash
      in commune: String then Commune.find_by!(name: hash.delete(:commune))
      in epci: String    then EPCI.find_by!(name: hash.delete(:epci))
      end

    hash[:publisher_id]   = publisher
    hash[:territory_type] = territory.class.name
    hash[:territory_id]   = territory.id
    hash[:name]           = territory.qualified_name
    hash
  end
end

Collectivity.insert_all(
  parse_collectivities([
    { publisher: "Fiscalité & Territoire", siren: "217500016", commune: "Paris" },
    { publisher: "Fiscalité & Territoire", siren: "200067106", epci: "CA du Pays Basque" },
    { publisher: "Fiscalité & Territoire", siren: "200093201", epci: "Métropole Européenne de Lille" },
    { publisher: "Fiscalité & Territoire", siren: "200054807", epci: "Métropole d'Aix-Marseille-Provence" },
    { publisher: "Fiscalité & Territoire", siren: "200067213", epci: "CU du Grand Reims" },
    { publisher: "Fiscalité & Territoire", siren: "243300316", epci: "Bordeaux Métropole" },
    { publisher: "Fiscalité & Territoire", siren: "243100518", epci: "Toulouse Métropole" },
    { publisher: "Fiscalité & Territoire", siren: "200039865", epci: "Metz Métropole" },
    { publisher: "Fiscalité & Territoire", siren: "249500109", epci: "CA de Cergy-Pontoise" },
    { publisher: "FININDEV", siren: "200046977", epci: "Métropole de Lyon" },
    { publisher: "FININDEV", siren: "243000643", epci: "CA de Nîmes Métropole" },
    { publisher: "INETUM", siren: "242100410", epci: "Dijon Métropole" },
    { publisher: "INETUM", siren: "243400017", epci: "Montpellier Méditerranée Métropole" }
  ])
)

# Import users
# ----------------------------------------------------------------------------
log "Seed users"

def parse_users(data)
  organizations = {}
    .merge(Collectivity.all.index_by(&:name))
    .merge(Publisher.all.index_by(&:name))
    .merge(DDFIP.all.index_by(&:name))

  data.map do |hash|
    organization = organizations[hash.delete(:organization)]

    hash[:organization_type] = organization.class.name
    hash[:organization_id]   = organization.id

    hash[:first_name] ||= Faker::Name.first_name
    hash[:last_name]  ||= Faker::Name.last_name
    hash[:name]         = hash.values_at(:first_name, :last_name).join(" ").strip

    hash[:confirmed_at] = hash.delete(:confirmed) ? Time.current : nil
    hash
  end
end

User.insert_all(
  parse_users([
    { email: "random@fu.example.org",            organization: "France Urbaine",                 organization_admin: true,  super_admin: true,  confirmed: true },
    { email: "random@ft.example.org",            organization: "Fiscalité & Territoire",         organization_admin: true,  super_admin: true,  confirmed: true },
    { email: "admin@pays-basque.example.org",    organization: "CA du Pays Basque",              organization_admin: true,  super_admin: false, confirmed: false },
    { email: "user@pays-basque.example.org",     organization: "CA du Pays Basque",              organization_admin: false, super_admin: false, confirmed: false },
    { email: "admin@ddfip-64.example.org",       organization: "DDFIP des Pyrénées-Atlantiques", organization_admin: true,  super_admin: false, confirmed: false },
    { email: "sdif@ddfip-64.example.org",        organization: "DDFIP des Pyrénées-Atlantiques", organization_admin: false, super_admin: false, confirmed: false },
    { email: "sip.bayonne@ddfip-64.example.org", organization: "DDFIP des Pyrénées-Atlantiques", organization_admin: false, super_admin: false, confirmed: false },
    { email: "sip.pau@ddfip-64.example.org",     organization: "DDFIP des Pyrénées-Atlantiques", organization_admin: false, super_admin: false, confirmed: false }
  ])
)

# Import offices
# ----------------------------------------------------------------------------
log "Seed offices"

def parse_offices(data)
  ddfips = DDFIP.pluck(:name, :id).to_h

  data.map do |hash|
    hash[:ddfip_id] = ddfips[hash.delete(:ddfip)]
    hash
  end
end

Office.insert_all(
  parse_offices([
    { ddfip: "DDFIP des Pyrénées-Atlantiques",                     name: "SDIF Pyrénées-Atlantiques - Bayonne",         action: "evaluation_hab" },
    { ddfip: "DDFIP des Pyrénées-Atlantiques",                     name: "SDIF Pyrénées-Atlantiques - Pau",             action: "evaluation_hab" },
    { ddfip: "DDFIP des Pyrénées-Atlantiques",                     name: "SIP de Bayonne-Anglet",                       action: "occupation_hab" },
    { ddfip: "DDFIP des Pyrénées-Atlantiques",                     name: "SIP de Biarritz",                             action: "occupation_hab" },
    { ddfip: "DDFIP des Pyrénées-Atlantiques",                     name: "SIE de Bayonne-Anglet",                       action: "occupation_eco" },
    { ddfip: "DDFIP des Pyrénées-Atlantiques",                     name: "SIE de Biarritz",                             action: "occupation_eco" },
    { ddfip: "DDFIP du Nord",                                      name: "SIP de Lille Nord",                           action: "occupation_hab" },
    { ddfip: "DDFIP du Nord",                                      name: "SIP de Lille Ouest",                          action: "occupation_hab" },
    { ddfip: "DDFIP du Nord",                                      name: "SIP de Lille Seclin",                         action: "occupation_hab" },
    { ddfip: "DRFIP Occitanie et département de la Haute-Garonne", name: "Pôle d’évaluation des locaux professionnels", action: "evaluation_eco" },
    { ddfip: "DRFIP Occitanie et département de la Haute-Garonne", name: "SIP de Balma",                                action: "occupation_hab" },
    { ddfip: "DRFIP Occitanie et département de la Haute-Garonne", name: "SIP de Colomiers",                            action: "occupation_hab" },
    { ddfip: "DRFIP Occitanie et département de la Haute-Garonne", name: "SIP de Muret",                                action: "occupation_hab" },
    { ddfip: "DRFIP Occitanie et département de la Haute-Garonne", name: "SIP de Saint-Gaudens",                        action: "occupation_hab" },
    { ddfip: "DRFIP Occitanie et département de la Haute-Garonne", name: "SIP de Toulouse Cité",                        action: "occupation_hab" },
    { ddfip: "DRFIP Occitanie et département de la Haute-Garonne", name: "SIP de Toulouse Mirail",                      action: "occupation_hab" },
    { ddfip: "DRFIP Occitanie et département de la Haute-Garonne", name: "SIP de Toulouse Rangueil",                    action: "occupation_hab" }
  ])
)

def parse_office_users(data)
  offices = Office.pluck(:name, :id).to_h
  users   = User.pluck(:email, :id).to_h

  data.map do |hash|
    hash[:office_id] = offices[hash.delete(:office)]
    hash[:user_id]   = users[hash.delete(:user)]
    hash
  end
end

OfficeUser.insert_all(
  parse_office_users([
    { user: "admin@ddfip-64.example.org",       office: "SDIF Pyrénées-Atlantiques - Bayonne" },
    { user: "admin@ddfip-64.example.org",       office: "SDIF Pyrénées-Atlantiques - Pau" },
    { user: "admin@ddfip-64.example.org",       office: "SIP de Bayonne-Anglet" },
    { user: "admin@ddfip-64.example.org",       office: "SIP de Biarritz" },
    { user: "admin@ddfip-64.example.org",       office: "SIE de Bayonne-Anglet" },
    { user: "admin@ddfip-64.example.org",       office: "SIE de Biarritz" },
    { user: "sdif@ddfip-64.example.org",        office: "SDIF Pyrénées-Atlantiques - Bayonne" },
    { user: "sdif@ddfip-64.example.org",        office: "SDIF Pyrénées-Atlantiques - Pau" },
    { user: "sip.bayonne@ddfip-64.example.org", office: "SIP de Bayonne-Anglet" }
  ])
)

def parse_office_communes(data)
  offices      = Office.pluck(:name, :id).to_h
  epcis        = Hash.new { |hash, name| hash[name] = EPCI.find_by!(name: name).communes.pluck(:code_insee) }
  departements = Hash.new { |hash, name| hash[name] = Departement.find_by!(name: name).communes.pluck(:code_insee) }

  data.flat_map do |hash|
    office_id   = offices[hash.delete(:office)]
    codes_insee =
      case hash
      in epci: String        then epcis[hash.delete(:epci)]
      in departement: String then departements[hash.delete(:departement)]
      end

    codes_insee.map do |code|
      { office_id: office_id, code_insee: code }
    end
  end
end

OfficeCommune.insert_all(
  parse_office_communes([
    { office: "SDIF Pyrénées-Atlantiques - Bayonne",         epci: "CA du Pays Basque" },
    { office: "SDIF Pyrénées-Atlantiques - Pau",             epci: "CA Pau Béarn Pyrénées" },
    { office: "SIP de Bayonne-Anglet",                       epci: "CA du Pays Basque" },
    { office: "SIP de Biarritz",                             epci: "CA du Pays Basque" },
    { office: "SIE de Bayonne-Anglet",                       epci: "CA du Pays Basque" },
    { office: "SIE de Biarritz",                             epci: "CA du Pays Basque" },
    { office: "SIP de Lille Nord",                           epci: "Métropole Européenne de Lille" },
    { office: "SIP de Lille Ouest",                          epci: "Métropole Européenne de Lille" },
    { office: "SIP de Lille Seclin",                         epci: "Métropole Européenne de Lille" },
    { office: "Pôle d’évaluation des locaux professionnels", departement: "Haute-Garonne" },
    { office: "SIP de Balma",                                epci: "Toulouse Métropole" },
    { office: "SIP de Colomiers",                            epci: "Toulouse Métropole" },
    { office: "SIP de Muret",                                epci: "Toulouse Métropole" },
    { office: "SIP de Toulouse Cité",                        epci: "Toulouse Métropole" },
    { office: "SIP de Toulouse Mirail",                      epci: "Toulouse Métropole" },
    { office: "SIP de Toulouse Rangueil",                    epci: "Toulouse Métropole" }
  ])
)

log ""
log "All seeds are ready."
log ""
log "-------------------------------------------------------------------------------------"
log "  For performances reasons, only few communes and EPCIs are created."
log "  To import all EPCIs and communes from a remote source, use the following command:"
log ""

if ENV["SETUP_SEED"] == "true"
  log "    bin/setup territories"
else
  log "    SEED_ALL_EPCIS_AND_COMMUNES=true rails db:seed"
end

log ""
log "  You can also create your own user to access the development server with the"
log "  following command:"
log ""

if ENV["SETUP_SEED"] == "true"
  log "    bin/setup user"
else
  log "    SEED_INTERACTIVE_USER=true rails db:seed"
end

log "-------------------------------------------------------------------------------------"
log ""