# frozen_string_literal: true

require "system_helper"

RSpec.describe "Communes" do
  fixtures :regions, :departements, :epcis, :communes
  fixtures :users

  let(:bayonne)              { communes(:bayonne) }
  let(:pays_basque)          { epcis(:pays_basque) }
  let(:pyrenees_atlantiques) { departements(:pyrenees_atlantiques) }
  let(:nouvelle_aquitaine)   { regions(:nouvelle_aquitaine) }

  before { sign_in(users(:marc)) }

  it "visits index & show pages" do
    visit communes_path

    expect(page).to have_selector("h1", text: "Communes")
    expect(page).to have_link("Bayonne")

    click_on "Bayonne"

    expect(page).to have_selector("h1", text: "Bayonne")
    expect(page).to have_current_path(commune_path(bayonne))
  end

  it "visits links from the show page & comes back" do
    visit commune_path(bayonne)

    expect(page).to have_selector("h1", text: "Bayonne")
    expect(page).to have_link("CA du Pays Basque")
    expect(page).to have_link("Pyrénées-Atlantiques")
    expect(page).to have_link("Nouvelle-Aquitaine")

    click_on "CA du Pays Basque"

    expect(page).to have_selector("h1", text: "CA du Pays Basque")
    expect(page).to have_current_path(epci_path(pays_basque))

    go_back

    expect(page).to have_selector("h1", text: "Bayonne")
    expect(page).to have_current_path(commune_path(bayonne))

    click_on "Pyrénées-Atlantiques"

    expect(page).to have_selector("h1", text: "Pyrénées-Atlantiques")
    expect(page).to have_current_path(departement_path(pyrenees_atlantiques))

    go_back

    expect(page).to have_selector("h1", text: "Bayonne")
    expect(page).to have_current_path(commune_path(bayonne))

    click_on "Nouvelle-Aquitaine"

    expect(page).to have_selector("h1", text: "Nouvelle-Aquitaine")
    expect(page).to have_current_path(region_path(nouvelle_aquitaine))

    go_back

    expect(page).to have_selector("h1", text: "Bayonne")
    expect(page).to have_current_path(commune_path(bayonne))
  end

  it "updates a commune from the index page" do
    visit communes_path

    # A button should be present to edit the collectivity
    #
    within "tr", text: "Bayonne" do |row|
      expect(row).to have_link("Modifier cette commune", class: "icon-button")

      click_on "Modifier cette commune"
    end

    # A dialog box should appear with a form
    # The form should be filled with collectivity data
    #
    expect(page).to have_selector("[role=dialog]", text: "Modification de la commune")

    within "[role=dialog]" do
      expect(page).to have_field("Nom de la commune", with: "Bayonne")
      expect(page).to have_field("Code INSEE",        with: "64102")
      expect(page).to have_field("Département",       with: "Pyrénées-Atlantiques")
      expect(page).to have_field("EPCI",              with: "CA du Pays Basque")

      fill_in  "Nom de la commune", with: "Nouvelle commune de Bayonne"
      click_on "Enregistrer"
    end

    # The browser should stay on index page
    # The collectivity should have changed its name
    #
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to     have_current_path(communes_path)
    expect(page).to     have_selector("h1", text: "Communes")
    expect(page).to     have_selector("tr", text: "Nouvelle commune de Bayonne")

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "updates a commune from the show page" do
    visit commune_path(bayonne)

    # A button should be present to edit the collectivity
    #
    within ".header-bar" do |header|
      expect(header).to have_selector("h1", text: "Bayonne")
      expect(header).to have_link("Modifier", class: "button")

      click_on "Modifier"
    end

    # A dialog box should appear with a form
    # The form should be filled with collectivity data
    #
    expect(page).to have_selector("[role=dialog]", text: "Modification de la commune")

    within "[role=dialog]" do
      expect(page).to have_field("Nom de la commune", with: "Bayonne")
      expect(page).to have_field("Code INSEE",        with: "64102")
      expect(page).to have_field("Département",       with: "Pyrénées-Atlantiques")
      expect(page).to have_field("EPCI",              with: "CA du Pays Basque")

      fill_in  "Nom de la commune", with: "Nouvelle commune de Bayonne"
      click_on "Enregistrer"
    end

    # The browser should stay on show page
    # The collectivity should have changed its name
    #
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to     have_current_path(commune_path(bayonne))
    expect(page).to     have_selector("h1", text: "Nouvelle commune de Bayonne")

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")
  end
end
