# frozen_string_literal: true

require "system_helper"

RSpec.describe "Managing communes" do
  fixtures :regions, :departements, :epcis, :communes
  fixtures :users

  let(:bayonne)              { communes(:bayonne) }
  let(:pays_basque)          { epcis(:pays_basque) }
  let(:pyrenees_atlantiques) { departements(:pyrenees_atlantiques) }
  let(:nouvelle_aquitaine)   { regions(:nouvelle_aquitaine) }

  before { sign_in(users(:marc)) }

  it "visits index & commune pages" do
    visit territories_communes_path

    # A table of all communes should be present
    #
    expect(page).to have_selector("h1", text: "Communes")
    expect(page).to have_selector("tr", text: "Bayonne")
    expect(page).to have_selector("tr", text: "Biarritz")
    expect(page).to have_selector("tr", text: "Pau")
    expect(page).to have_selector("tr", text: "Lille")

    click_on "Bayonne"

    # The browser should visit the commune page
    #
    expect(page).to have_current_path(territories_commune_path(bayonne))
    expect(page).to have_selector("h1", text: "Bayonne")

    go_back

    # The browser should redirect back to the index page
    #
    expect(page).to have_current_path(territories_communes_path)
    expect(page).to have_selector("h1", text: "Communes")
  end

  it "visits the links on a commune page & comes back" do
    visit territories_commune_path(bayonne)

    # On the collectivity page, we expect:
    # - a link to the EPCI
    # - a link to the departement
    # - a link to the region
    #
    expect(page).to have_selector("h1", text: "Bayonne")
    expect(page).to have_link("CA du Pays Basque")
    expect(page).to have_link("Pyrénées-Atlantiques")
    expect(page).to have_link("Nouvelle-Aquitaine")

    click_on "CA du Pays Basque"

    # The browser should visit the EPCI page
    #
    expect(page).to have_current_path(territories_epci_path(pays_basque))
    expect(page).to have_selector("h1", text: "CA du Pays Basque")

    go_back

    # The browser should redirect back to the commune page
    #
    expect(page).to have_current_path(territories_commune_path(bayonne))
    expect(page).to have_selector("h1", text: "Bayonne")

    click_on "Pyrénées-Atlantiques"

    # The browser should visit the departement page
    #
    expect(page).to have_current_path(territories_departement_path(pyrenees_atlantiques))
    expect(page).to have_selector("h1", text: "Pyrénées-Atlantiques")

    go_back

    # The browser should redirect back to the commune page
    #
    expect(page).to have_current_path(territories_commune_path(bayonne))
    expect(page).to have_selector("h1", text: "Bayonne")

    click_on "Nouvelle-Aquitaine"

    # The browser should visit the region page
    #
    expect(page).to have_current_path(territories_region_path(nouvelle_aquitaine))
    expect(page).to have_selector("h1", text: "Nouvelle-Aquitaine")

    go_back

    # The browser should redirect back to the commune page
    #
    expect(page).to have_current_path(territories_commune_path(bayonne))
    expect(page).to have_selector("h1", text: "Bayonne")
  end

  it "updates a commune from the index page" do
    visit territories_communes_path

    # A button should be present to edit the commune
    #
    within "tr", text: "Bayonne" do
      click_on "Modifier cette commune"
    end

    # A dialog box should appear with a form
    # The form should be filled with collectivity data
    #
    within "[role=dialog]", text: "Modification de la commune" do |dialog|
      expect(dialog).to have_field("Nom de la commune", with: "Bayonne")
      expect(dialog).to have_field("Code INSEE",        with: "64102")
      expect(dialog).to have_field("Département",       with: "Pyrénées-Atlantiques")
      expect(dialog).to have_field("EPCI",              with: "CA du Pays Basque")

      fill_in  "Nom de la commune", with: "Nouvelle commune de Bayonne"
      click_on "Enregistrer"
    end

    # The browser should stay on index page
    # The collectivity should have changed its name
    #
    expect(page).to have_current_path(territories_communes_path)
    expect(page).to have_selector("h1", text: "Communes")
    expect(page).to have_selector("tr", text: "Nouvelle commune de Bayonne")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=log]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "updates a commune from the commune page" do
    visit territories_commune_path(bayonne)

    # A button should be present to edit the commune
    #
    within ".breadcrumbs", text: "Bayonne" do
      click_on "Modifier"
    end

    # A dialog box should appear with a form
    # The form should be filled with collectivity data
    #
    within "[role=dialog]", text: "Modification de la commune" do |dialog|
      expect(dialog).to have_field("Nom de la commune", with: "Bayonne")
      expect(dialog).to have_field("Code INSEE",        with: "64102")
      expect(dialog).to have_field("Département",       with: "Pyrénées-Atlantiques")
      expect(dialog).to have_field("EPCI",              with: "CA du Pays Basque")

      fill_in  "Nom de la commune", with: "Nouvelle commune de Bayonne"
      click_on "Enregistrer"
    end

    # The browser should stay on show page
    # The collectivity should have changed its name
    #
    expect(page).to have_current_path(territories_commune_path(bayonne))
    expect(page).to have_selector("h1", text: "Nouvelle commune de Bayonne")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=log]", text: "Les modifications ont été enregistrées avec succés.")
  end
end
