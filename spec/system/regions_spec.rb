# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Regions", type: :system, use_fixtures: true do
  fixtures :communes, :epcis, :departements, :regions, :ddfips

  let(:nouvelle_aquitaine)   { regions(:nouvelle_aquitaine) }
  let(:pyrenees_atlantiques) { departements(:pyrenees_atlantiques) }
  let(:ddfip64)              { ddfips(:pyrenees_atlantiques) }

  it "visits index & show pages" do
    visit regions_path

    expect(page).to have_selector("h1", text: "Régions")
    expect(page).to have_link("Nouvelle-Aquitaine")

    click_on "Nouvelle-Aquitaine"

    expect(page).to have_current_path(region_path(nouvelle_aquitaine, back: regions_path))
    expect(page).to have_selector("h1", text: "Nouvelle-Aquitaine")
  end

  it "visits links from the show page & comes back" do
    visit region_path(nouvelle_aquitaine)

    expect(page).to have_selector("h1", text: "Nouvelle-Aquitaine")
    expect(page).to have_link("Pyrénées-Atlantiques")
    expect(page).to have_link("Voir les EPCI")
    expect(page).to have_link("Voir les communes")
    expect(page).to have_link("DDFIP des Pyrénées-Atlantiques")

    click_on "Pyrénées-Atlantiques"

    expect(page).to have_current_path(departement_path(pyrenees_atlantiques, back: region_path(nouvelle_aquitaine)))

    go_back
    click_on "Voir les EPCI"

    expect(page).to have_current_path(epcis_path(search: "Nouvelle-Aquitaine"))
    expect(page).to have_selector("tr", text: "CA du Pays Basque")

    go_back
    click_on "Voir les communes"

    expect(page).to have_current_path(communes_path(search: "Nouvelle-Aquitaine"))
    expect(page).to have_selector("tr", text: "Bayonne")

    go_back
    click_on "DDFIP des Pyrénées-Atlantiques"

    expect(page).to have_current_path(ddfip_path(ddfip64, back: region_path(nouvelle_aquitaine)))

    go_back

    expect(page).to have_current_path(region_path(nouvelle_aquitaine))
  end

  it "updates a region from index page" do
    visit regions_path

    within "tr", text: "Nouvelle-Aquitaine" do
      click_on "Modifier cette région"
    end

    expect(page).to have_selector("[role=dialog]", text: "Modification de la région")

    within "[role=dialog]" do
      expect(page).to have_field("Nom de la région",        with: "Nouvelle-Aquitaine")
      expect(page).to have_field("Code INSEE de la région", with: "75")

      fill_in  "Nom de la région", with: "Nouvelle nouvelle Aquitaine"
      click_on "Enregistrer"
    end

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")

    expect(page).to have_current_path(regions_path)
    expect(page).to have_selector("tr", text: "Nouvelle nouvelle Aquitaine")
  end

  it "updates a region from the show page" do
    visit region_path(nouvelle_aquitaine)

    expect(page).to have_selector("h1", text: "Nouvelle-Aquitaine")
    expect(page).to have_link("Modifier")

    click_on "Modifier"

    expect(page).to have_selector("[role=dialog]", text: "Modification de la région")

    within "[role=dialog]" do
      expect(page).to have_field("Nom de la région", with: "Nouvelle-Aquitaine")
      expect(page).to have_field("Code INSEE de la région", with: "75")

      fill_in  "Nom de la région", with: "Nouvelle nouvelle Aquitaine"
      click_on "Enregistrer"
    end

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")

    expect(page).to have_current_path(region_path(nouvelle_aquitaine))
    expect(page).to have_selector("h1", text: "Nouvelle nouvelle Aquitaine")
  end
end
