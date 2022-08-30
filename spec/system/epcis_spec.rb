# frozen_string_literal: true

require "rails_helper"

RSpec.describe "EPCIs", type: :system, use_fixtures: true do
  fixtures :communes, :epcis, :departements, :regions

  let(:pays_basque)          { epcis(:pays_basque) }
  let(:pyrenees_atlantiques) { departements(:pyrenees_atlantiques) }

  it "visits index & show pages" do
    visit epcis_path

    expect(page).to have_selector("h1", text: "EPCI")
    expect(page).to have_link("CA du Pays Basque")

    click_on "CA du Pays Basque"

    expect(page).to have_current_path(epci_path(pays_basque, back: epcis_path))
    expect(page).to have_selector("h1", text: "CA du Pays Basque")
  end

  it "visits links from the show page & comes back" do
    visit epci_path(pays_basque)

    expect(page).to have_selector("h1", text: "CA du Pays Basque")
    expect(page).to have_link("Pyrénées-Atlantiques")
    expect(page).to have_link("Voir les communes")

    click_on "Pyrénées-Atlantiques"

    expect(page).to have_current_path(departement_path(pyrenees_atlantiques))

    go_back
    click_on "Voir les communes"

    expect(page).to have_current_path(communes_path(search: "200067106"))
    expect(page).to have_selector("tr", text: "Bayonne")

    go_back

    expect(page).to have_current_path(epci_path(pays_basque))
  end

  it "updates an EPCI from the index page" do
    visit epcis_path

    within "tr", text: "CA du Pays Basque" do
      click_on "Modifier cet EPCI"
    end

    expect(page).to have_selector("[role=dialog]", text: "Modification de l'EPCI")

    within "[role=dialog]" do
      expect(page).to have_field("Nom de l'EPCI",          with: "CA du Pays Basque")
      expect(page).to have_field("Numéro SIREN de l'EPCI", with: "200067106")
      expect(page).to have_field("Département",            with: "Pyrénées-Atlantiques")

      fill_in  "Nom de l'EPCI", with: "Agglomération Pays Basque"
      click_on "Enregistrer"
    end

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")

    expect(page).to have_current_path(epcis_path)
    expect(page).to have_selector("tr", text: "Agglomération Pays Basque")
  end

  it "updates an EPCI from the show page" do
    visit epci_path(pays_basque)

    click_on "Modifier"

    expect(page).to have_selector("[role=dialog]", text: "Modification de l'EPCI")

    within "[role=dialog]" do
      expect(page).to have_field("Nom de l'EPCI",          with: "CA du Pays Basque")
      expect(page).to have_field("Numéro SIREN de l'EPCI", with: "200067106")
      expect(page).to have_field("Département",            with: "Pyrénées-Atlantiques")

      fill_in  "Nom de l'EPCI", with: "Agglomération Pays Basque"
      click_on "Enregistrer"
    end

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")

    expect(page).to have_current_path(epci_path(pays_basque))
    expect(page).to have_selector("h1", text: "Agglomération Pays Basque")
  end
end
