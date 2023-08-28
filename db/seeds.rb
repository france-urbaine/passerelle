# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

require_relative "seeds/helpers"

# Import EPCIs and communes from a remote source
# ----------------------------------------------------------------------------
if ENV["SEED_ALL_EPCIS_AND_COMMUNES"] == "true"
  require_relative "seeds/epcis_and_communes"
  exit
end

# Seed one user through interactive command
# ----------------------------------------------------------------------------
if ENV["SEED_INTERACTIVE_USER"] == "true"
  require_relative "seeds/interactive_user"
  exit
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

Office.insert_all(
  parse_offices([
    { ddfip: "DDFIP des Pyrénées-Atlantiques",                     name: "SDIF Pyrénées-Atlantiques - Bayonne", competences: %w[evaluation_local_habitation evaluation_local_professionnel] },
    { ddfip: "DDFIP des Pyrénées-Atlantiques",                     name: "SDIF Pyrénées-Atlantiques - Pau",     competences: %w[evaluation_local_habitation evaluation_local_professionnel] },
    { ddfip: "DDFIP des Pyrénées-Atlantiques",                     name: "SIP de Bayonne-Anglet",               competences: %w[occupation_local_habitation] },
    { ddfip: "DDFIP des Pyrénées-Atlantiques",                     name: "SIP de Biarritz",                     competences: %w[occupation_local_habitation] },
    { ddfip: "DDFIP des Pyrénées-Atlantiques",                     name: "SIE de Bayonne-Anglet",               competences: %w[occupation_local_professionnel] },
    { ddfip: "DDFIP des Pyrénées-Atlantiques",                     name: "SIE de Biarritz",                     competences: %w[occupation_local_professionnel] },
    { ddfip: "DDFIP du Nord",                                      name: "SIP de Lille Nord",                   competences: %w[occupation_local_habitation] },
    { ddfip: "DDFIP du Nord",                                      name: "SIP de Lille Ouest",                  competences: %w[occupation_local_habitation] },
    { ddfip: "DDFIP du Nord",                                      name: "SIP de Lille Seclin",                 competences: %w[occupation_local_habitation] },
    { ddfip: "DRFIP Occitanie et département de la Haute-Garonne", name: "PELP de Haute-Garonne",               competences: %w[evaluation_local_professionnel] },
    { ddfip: "DRFIP Occitanie et département de la Haute-Garonne", name: "SIP de Balma",                        competences: %w[occupation_local_habitation] },
    { ddfip: "DRFIP Occitanie et département de la Haute-Garonne", name: "SIP de Colomiers",                    competences: %w[occupation_local_habitation] },
    { ddfip: "DRFIP Occitanie et département de la Haute-Garonne", name: "SIP de Muret",                        competences: %w[occupation_local_habitation] },
    { ddfip: "DRFIP Occitanie et département de la Haute-Garonne", name: "SIP de Saint-Gaudens",                competences: %w[occupation_local_habitation] },
    { ddfip: "DRFIP Occitanie et département de la Haute-Garonne", name: "SIP de Toulouse Cité",                competences: %w[occupation_local_habitation] },
    { ddfip: "DRFIP Occitanie et département de la Haute-Garonne", name: "SIP de Toulouse Mirail",              competences: %w[occupation_local_habitation] },
    { ddfip: "DRFIP Occitanie et département de la Haute-Garonne", name: "SIP de Toulouse Rangueil",            competences: %w[occupation_local_habitation] }
  ])
)

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

OfficeCommune.insert_all(
  parse_office_communes([
    { office: "SDIF Pyrénées-Atlantiques - Bayonne", epci: "CA du Pays Basque" },
    { office: "SDIF Pyrénées-Atlantiques - Pau",     epci: "CA Pau Béarn Pyrénées" },
    { office: "SIP de Bayonne-Anglet",               epci: "CA du Pays Basque" },
    { office: "SIP de Biarritz",                     epci: "CA du Pays Basque" },
    { office: "SIE de Bayonne-Anglet",               epci: "CA du Pays Basque" },
    { office: "SIE de Biarritz",                     epci: "CA du Pays Basque" },
    { office: "SIP de Lille Nord",                   epci: "Métropole Européenne de Lille" },
    { office: "SIP de Lille Ouest",                  epci: "Métropole Européenne de Lille" },
    { office: "SIP de Lille Seclin",                 epci: "Métropole Européenne de Lille" },
    { office: "PELP de Haute-Garonne",               departement: "Haute-Garonne" },
    { office: "SIP de Balma",                        epci: "Toulouse Métropole" },
    { office: "SIP de Colomiers",                    epci: "Toulouse Métropole" },
    { office: "SIP de Muret",                        epci: "Toulouse Métropole" },
    { office: "SIP de Toulouse Cité",                epci: "Toulouse Métropole" },
    { office: "SIP de Toulouse Mirail",              epci: "Toulouse Métropole" },
    { office: "SIP de Toulouse Rangueil",            epci: "Toulouse Métropole" }
  ])
)

log ""
log "All seeds are ready."
log ""
log "-------------------------------------------------------------------------------------"
log "For performances reasons, only few communes and EPCIs are created."
log "To import all EPCIs and communes from a remote source, use the following command:"
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

log ""
log "-------------------------------------------------------------------------------------"
log ""
