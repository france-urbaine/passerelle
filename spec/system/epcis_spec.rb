# frozen_string_literal: true

require "system_helper"

RSpec.describe "EPCIs" do
  fixtures :regions, :departements, :epcis, :communes
  fixtures :users

  let(:pays_basque)          { epcis(:pays_basque) }
  let(:pyrenees_atlantiques) { departements(:pyrenees_atlantiques) }

  before { sign_in(users(:marc)) }

  it "visits index & show pages" do
    visit epcis_path

    expect(page).to have_selector("h1", text: "EPCI")
    expect(page).to have_link("CA du Pays Basque")

    click_on "CA du Pays Basque"

    expect(page).to have_selector("h1", text: "CA du Pays Basque")
    expect(page).to have_current_path(epci_path(pays_basque))
  end

  it "visits links from the show page & comes back" do
    visit epci_path(pays_basque)

    expect(page).to have_selector("h1", text: "CA du Pays Basque")
    expect(page).to have_link("Pyrénées-Atlantiques")
    expect(page).to have_link("Voir les communes")

    click_on "Pyrénées-Atlantiques"

    expect(page).to have_selector("h1", text: "Pyrénées-Atlantiques")
    expect(page).to have_current_path(departement_path(pyrenees_atlantiques))

    go_back

    expect(page).to have_selector("h1", text: "CA du Pays Basque")
    expect(page).to have_current_path(epci_path(pays_basque))

    click_on "Voir les communes"

    expect(page).to have_selector("h1", text: "Communes")
    expect(page).to have_selector("tr", text: "Bayonne")
    expect(page).to have_current_path(communes_path(search: "200067106"))

    go_back

    expect(page).to have_selector("h1", text: "CA du Pays Basque")
    expect(page).to have_current_path(epci_path(pays_basque))
  end

  it "updates an EPCI from the index page" do
    visit epcis_path

    # A button should be present to edit the collectivity
    #
    within "tr", text: "CA du Pays Basque" do |row|
      expect(row).to have_link("Modifier cet EPCI", class: "icon-button")

      click_on "Modifier cet EPCI"
    end

    # A dialog box should appear with a form
    # The form should be filled with collectivity data
    #
    expect(page).to have_selector("[role=dialog]", text: "Modification de l'EPCI")

    within "[role=dialog]" do
      expect(page).to have_field("Nom de l'EPCI",          with: "CA du Pays Basque")
      expect(page).to have_field("Numéro SIREN de l'EPCI", with: "200067106")
      expect(page).to have_field("Département",            with: "Pyrénées-Atlantiques")

      fill_in  "Nom de l'EPCI", with: "Agglomération Pays Basque"
      click_on "Enregistrer"
    end

    # The browser should stay on index page
    # The collectivity should have changed its name
    #
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to     have_current_path(epcis_path)
    expect(page).to     have_selector("h1", text: "EPCI")
    expect(page).to     have_selector("tr", text: "Agglomération Pays Basque")

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "updates an EPCI from the show page" do
    visit epci_path(pays_basque)

    # A button should be present to edit the collectivity
    #
    within ".header-bar" do |header|
      expect(header).to have_selector("h1", text: "CA du Pays Basque")
      expect(header).to have_link("Modifier", class: "button")

      click_on "Modifier"
    end

    # A dialog box should appear with a form
    # The form should be filled with collectivity data
    #
    expect(page).to have_selector("[role=dialog]", text: "Modification de l'EPCI")

    within "[role=dialog]" do
      expect(page).to have_field("Nom de l'EPCI",          with: "CA du Pays Basque")
      expect(page).to have_field("Numéro SIREN de l'EPCI", with: "200067106")
      expect(page).to have_field("Département",            with: "Pyrénées-Atlantiques")

      fill_in  "Nom de l'EPCI", with: "Agglomération Pays Basque"
      click_on "Enregistrer"
    end

    # The browser should stay on show page
    # The collectivity should have changed its name
    #
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to     have_current_path(epci_path(pays_basque))
    expect(page).to     have_selector("h1", text: "Agglomération Pays Basque")

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")
  end
end
