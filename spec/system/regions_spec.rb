# frozen_string_literal: true

require "system_helper"

RSpec.describe "Regions" do
  fixtures :regions, :departements, :epcis, :communes
  fixtures :ddfips

  let(:nouvelle_aquitaine)   { regions(:nouvelle_aquitaine) }
  let(:pyrenees_atlantiques) { departements(:pyrenees_atlantiques) }
  let(:ddfip64)              { ddfips(:pyrenees_atlantiques) }

  it "visits index & show pages" do
    visit regions_path

    expect(page).to have_selector("h1", text: "Régions")
    expect(page).to have_link("Nouvelle-Aquitaine")

    click_on "Nouvelle-Aquitaine"

    expect(page).to have_selector("h1", text: "Nouvelle-Aquitaine")
    expect(page).to have_current_path(region_path(nouvelle_aquitaine))
  end

  it "visits links from the show page & comes back" do
    visit region_path(nouvelle_aquitaine)

    expect(page).to have_selector("h1", text: "Nouvelle-Aquitaine")
    expect(page).to have_link("Pyrénées-Atlantiques")
    expect(page).to have_link("Voir les EPCIs")
    expect(page).to have_link("Voir les communes")
    expect(page).to have_link("DDFIP des Pyrénées-Atlantiques")

    click_on "Pyrénées-Atlantiques"

    expect(page).to have_selector("h1", text: "Pyrénées-Atlantiques")
    expect(page).to have_current_path(departement_path(pyrenees_atlantiques))

    go_back

    expect(page).to have_selector("h1", text: "Nouvelle-Aquitaine")
    expect(page).to have_current_path(region_path(nouvelle_aquitaine))

    click_on "Voir les EPCIs"

    expect(page).to have_selector("h1", text: "EPCI")
    expect(page).to have_selector("tr", text: "CA du Pays Basque")
    expect(page).to have_current_path(epcis_path(search: "Nouvelle-Aquitaine"))

    go_back

    expect(page).to have_selector("h1", text: "Nouvelle-Aquitaine")
    expect(page).to have_current_path(region_path(nouvelle_aquitaine))

    click_on "Voir les communes"

    expect(page).to have_selector("h1", text: "Communes")
    expect(page).to have_selector("tr", text: "Bayonne")
    expect(page).to have_current_path(communes_path(search: "Nouvelle-Aquitaine"))

    go_back

    expect(page).to have_selector("h1", text: "Nouvelle-Aquitaine")
    expect(page).to have_current_path(region_path(nouvelle_aquitaine))

    click_on "DDFIP des Pyrénées-Atlantiques"

    expect(page).to have_selector("h1", text: "DDFIP des Pyrénées-Atlantiques")
    expect(page).to have_current_path(ddfip_path(ddfip64))

    go_back

    expect(page).to have_selector("h1", text: "Nouvelle-Aquitaine")
    expect(page).to have_current_path(region_path(nouvelle_aquitaine))
  end

  it "updates a region from index page" do
    visit regions_path

    # A button should be present to edit the collectivity
    #
    within "tr", text: "Nouvelle-Aquitaine" do |row|
      expect(row).to have_link("Modifier cette région", class: "icon-button")

      click_on "Modifier cette région"
    end

    # A dialog box should appears with a form
    # The form should be filled with collectivity data
    #
    expect(page).to have_selector("[role=dialog]", text: "Modification de la région")

    within "[role=dialog]" do
      expect(page).to have_field("Nom de la région",        with: "Nouvelle-Aquitaine")
      expect(page).to have_field("Code INSEE de la région", with: "75")

      fill_in  "Nom de la région", with: "Nouvelle Aquitaine indépendante !"
      click_on "Enregistrer"
    end

    # The browser should stay on index page
    # The collectivity should have changed its name
    #
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to     have_current_path(regions_path)
    expect(page).to     have_selector("h1", text: "Régions")
    expect(page).to     have_selector("tr", text: "Nouvelle Aquitaine indépendante !")

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "updates a region from the show page" do
    visit region_path(nouvelle_aquitaine)

    # A button should be present to edit the collectivity
    #
    within ".header-bar" do |header|
      expect(header).to have_selector("h1", text: "Nouvelle-Aquitaine")
      expect(header).to have_link("Modifier", class: "button")

      click_on "Modifier"
    end

    # A dialog box should appears with a form
    # The form should be filled with collectivity data
    #
    expect(page).to have_selector("[role=dialog]", text: "Modification de la région")

    within "[role=dialog]" do
      expect(page).to have_field("Nom de la région", with: "Nouvelle-Aquitaine")
      expect(page).to have_field("Code INSEE de la région", with: "75")

      fill_in  "Nom de la région", with: "Nouvelle Aquitaine indépendante !"
      click_on "Enregistrer"
    end

    # The browser should stay on show page
    # The collectivity should have changed its name
    #
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to     have_current_path(region_path(nouvelle_aquitaine))
    expect(page).to     have_selector("h1", text: "Nouvelle Aquitaine indépendante !")

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")
  end
end
