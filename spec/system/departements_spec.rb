# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Departements", use_fixtures: true do
  fixtures :communes, :epcis, :departements, :regions, :ddfips

  let(:nord)            { departements(:nord) }
  let(:hauts_de_france) { regions(:hauts_de_france) }
  let(:ddfip59)         { ddfips(:nord) }

  it "visits index & show pages" do
    visit departements_path

    expect(page).to have_selector("h1", text: "Départements")
    expect(page).to have_link("Nord")

    click_on "Nord"

    expect(page).to have_selector("h1", text: "Nord")
    expect(page).to have_current_path(departement_path(nord))
  end

  it "visits links from the show page & comes back" do
    visit departement_path(nord)

    expect(page).to have_selector("h1", text: "Nord")
    expect(page).to have_link("Hauts-de-France")
    expect(page).to have_link("Voir les EPCI")
    expect(page).to have_link("Voir les communes")
    expect(page).to have_link("DDFIP du Nord")

    click_on "Hauts-de-France"

    expect(page).to have_selector("h1", text: "Hauts-de-France")
    expect(page).to have_current_path(region_path(hauts_de_france))

    go_back

    expect(page).to have_selector("h1", text: "Nord")
    expect(page).to have_current_path(departement_path(nord))

    click_on "Voir les EPCI"

    expect(page).to have_selector("h1", text: "EPCI")
    expect(page).to have_selector("tr", text: "Métropole Européenne de Lille")
    expect(page).to have_current_path(epcis_path(search: "59"))

    go_back

    expect(page).to have_selector("h1", text: "Nord")
    expect(page).to have_current_path(departement_path(nord))

    click_on "Voir les communes"

    expect(page).to have_selector("h1", text: "Communes")
    expect(page).to have_selector("tr", text: "Lille")
    expect(page).to have_current_path(communes_path(search: "59"))

    go_back

    expect(page).to have_selector("h1", text: "Nord")
    expect(page).to have_current_path(departement_path(nord))

    click_on "DDFIP du Nord"

    expect(page).to have_selector("h1", text: "DDFIP du Nord")
    expect(page).to have_current_path(ddfip_path(ddfip59))

    go_back

    expect(page).to have_selector("h1", text: "Nord")
    expect(page).to have_current_path(departement_path(nord))
  end

  it "updates a departement from the index page" do
    visit departements_path

    within "tr", text: "Nord" do
      click_on "Modifier ce département"
    end

    expect(page).to have_selector("[role=dialog]", text: "Modification du département")

    within "[role=dialog]" do
      expect(page).to have_field("Nom du département",        with: "Nord")
      expect(page).to have_field("Code INSEE du département", with: "59")
      expect(page).to have_field("Région",                    with: "Hauts-de-France")

      fill_in  "Nom du département", with: "Département du Nord"
      click_on "Enregistrer"
    end

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")

    expect(page).to have_current_path(departements_path)
    expect(page).to have_selector("tr", text: "Département du Nord")
  end

  it "updates a departement from the show page" do
    visit departement_path(nord)

    click_on "Modifier"

    expect(page).to have_selector("[role=dialog]", text: "Modification du département")

    within "[role=dialog]" do
      expect(page).to have_field("Nom du département",        with: "Nord")
      expect(page).to have_field("Code INSEE du département", with: "59")
      expect(page).to have_field("Région",                    with: "Hauts-de-France")

      fill_in  "Nom du département", with: "Département du Nord"
      click_on "Enregistrer"
    end

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")

    expect(page).to have_current_path(departement_path(nord))
    expect(page).to have_selector("h1", text: "Département du Nord")
  end
end
