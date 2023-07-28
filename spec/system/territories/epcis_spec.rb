# frozen_string_literal: true

require "system_helper"

RSpec.describe "EPCIs" do
  fixtures :regions, :departements, :epcis, :communes
  fixtures :users

  let(:pays_basque)          { epcis(:pays_basque) }
  let(:pyrenees_atlantiques) { departements(:pyrenees_atlantiques) }
  let(:nouvelle_aquitaine)   { regions(:nouvelle_aquitaine) }

  before { sign_in(users(:marc)) }

  it "visits index & EPCI pages" do
    visit territories_epcis_path

    # A table of all communes should be present
    #
    expect(page).to have_selector("h1", text: "EPCI")
    expect(page).to have_selector("tr", text: "CA du Pays Basque")
    expect(page).to have_selector("tr", text: "CA Pau Béarn Pyrénées")
    expect(page).to have_selector("tr", text: "Métropole Européenne de Lille")

    click_on "CA du Pays Basque"

    # The browser should visit the EPCI page
    #
    expect(page).to have_current_path(territories_epci_path(pays_basque))
    expect(page).to have_selector("h1", text: "CA du Pays Basque")

    go_back

    # The browser should redirect back to the index page
    #
    expect(page).to have_current_path(territories_epcis_path)
    expect(page).to have_selector("h1", text: "EPCI")
  end

  it "visits links on an EPCI page & comes back" do
    visit territories_epci_path(pays_basque)

    # On the collectivity page, we expect:
    # - a link to the departement
    # - a link to the region
    #
    expect(page).to have_selector("h1", text: "CA du Pays Basque")
    expect(page).to have_link("Pyrénées-Atlantiques")
    expect(page).to have_link("Nouvelle-Aquitaine")

    click_on "Pyrénées-Atlantiques", match: :first

    # The browser should visit the departement page
    #
    expect(page).to have_current_path(territories_departement_path(pyrenees_atlantiques))
    expect(page).to have_selector("h1", text: "Pyrénées-Atlantiques")

    go_back

    # The browser should redirect back to the EPCI page
    #
    expect(page).to have_current_path(territories_epci_path(pays_basque))
    expect(page).to have_selector("h1", text: "CA du Pays Basque")

    click_on "Nouvelle-Aquitaine"

    # The browser should visit the region page
    #
    expect(page).to have_current_path(territories_region_path(nouvelle_aquitaine))
    expect(page).to have_selector("h1", text: "Nouvelle-Aquitaine")

    go_back

    # The browser should redirect back to the EPCI page
    #
    expect(page).to have_current_path(territories_epci_path(pays_basque))
    expect(page).to have_selector("h1", text: "CA du Pays Basque")
  end

  it "updates an EPCI from the index page" do
    visit territories_epcis_path

    # A button should be present to edit the collectivity
    #
    within "tr", text: "CA du Pays Basque" do
      click_on "Modifier cet EPCI"
    end

    # A dialog box should appear with a form
    # The form should be filled with collectivity data
    #
    within "[role=dialog]", text: "Modification de l'EPCI" do |dialog|
      expect(dialog).to have_field("Nom de l'EPCI",          with: "CA du Pays Basque")
      expect(dialog).to have_field("Numéro SIREN de l'EPCI", with: "200067106")
      expect(dialog).to have_field("Département",            with: "Pyrénées-Atlantiques")

      fill_in  "Nom de l'EPCI", with: "Agglomération Pays Basque"
      click_on "Enregistrer"
    end

    # The browser should stay on index page
    # The collectivity should have changed its name
    #
    expect(page).to have_current_path(territories_epcis_path)
    expect(page).to have_selector("h1", text: "EPCI")
    expect(page).to have_selector("tr", text: "Agglomération Pays Basque")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "updates an EPCI from the EPCI page" do
    visit territories_epci_path(pays_basque)

    # A button should be present to edit the collectivity
    #
    within ".header-bar", text: "CA du Pays Basque" do
      click_on "Modifier"
    end

    # A dialog box should appear with a form
    # The form should be filled with collectivity data
    #
    within "[role=dialog]", text: "Modification de l'EPCI" do |dialog|
      expect(dialog).to have_field("Nom de l'EPCI",          with: "CA du Pays Basque")
      expect(dialog).to have_field("Numéro SIREN de l'EPCI", with: "200067106")
      expect(dialog).to have_field("Département",            with: "Pyrénées-Atlantiques")

      fill_in  "Nom de l'EPCI", with: "Agglomération Pays Basque"
      click_on "Enregistrer"
    end

    # The browser should stay on show page
    # The collectivity should have changed its name
    #
    expect(page).to     have_current_path(territories_epci_path(pays_basque))
    expect(page).to     have_selector("h1", text: "Agglomération Pays Basque")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")
  end
end
