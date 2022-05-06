# frozen_string_literal: true

require "rails_helper"

RSpec.describe "EPCIs", type: :system, use_fixtures: true do
  fixtures :epcis, :departements, :regions

  it "visits index & show pages" do
    visit epcis_path

    expect(page).to have_selector("h1", text: "EPCI")
    expect(page).to have_link("CA du Pays Basque")

    click_on "CA du Pays Basque"

    expect(page).to have_current_path(%r{^/epcis/.{36}})
    expect(page).to have_selector("h1", text: "CA du Pays Basque")
  end

  it "updates an EPCI from index page" do
    visit epcis_path

    expect(page).to have_selector("h1", text: "EPCI")
    expect(page).to have_link("CA du Pays Basque")

    within "tr", text: "CA du Pays Basque" do
      click_on "Modifier cet EPCI"
    end

    expect(page).to have_selector("[role=dialog]", text: "Modification de l'EPCI")
    expect(page).to have_field("Nom de l'EPCI", with: "CA du Pays Basque")

    within "[role=dialog]" do
      fill_in  "Nom de l'EPCI", with: "Agglomération Pays Basque"
      click_on "Enregistrer"
    end

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")

    expect(page).to have_selector("h1", text: "EPCI")
    expect(page).to have_link("Agglomération Pays Basque")
  end

  it "updates an EPCI from the show page" do
    visit epci_path(epcis(:pays_basque))

    expect(page).to have_selector("h1", text: "CA du Pays Basque")
    expect(page).to have_link("Modifier")

    click_on "Modifier"

    expect(page).to have_selector("[role=dialog]", text: "Modification de l'EPCI")
    expect(page).to have_field("Nom de l'EPCI", with: "CA du Pays Basque")

    within "[role=dialog]" do
      fill_in  "Nom de l'EPCI", with: "Agglomération Pays Basque"
      click_on "Enregistrer"
    end

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")

    expect(page).to have_selector("h1", text: "Agglomération Pays Basque")
  end
end
