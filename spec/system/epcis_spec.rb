# frozen_string_literal: true

require "rails_helper"

RSpec.describe "EPCIs", type: :system do
  let!(:pays_basque) { create(:epci, name: "CA Pays Basque") }

  it "visits index & show pages" do
    visit epcis_path

    expect(page).to have_selector("h1", text: "Base de données des EPCI")
    expect(page).to have_link("CA Pays Basque")

    click_on "CA Pays Basque"

    expect(page).to have_current_path(%r{^/epcis/#{pays_basque.id}})
    expect(page).to have_selector("h1", text: "CA Pays Basque")
  end

  it "updates an EPCI from index page" do
    visit epcis_path

    expect(page).to have_selector("h1", text: "Base de données des EPCI")
    expect(page).to have_link("CA Pays Basque")

    click_on "Modifier cet EPCI", match: :first

    expect(page).to have_selector("[role=dialog]", text: "Modification de l'EPCI")

    fill_in "Nom de l'EPCI", with: "CA du Pays Basque"
    click_on "Enregistrer"

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")

    expect(page).to have_selector("h1", text: "Base de données des EPCI")
    expect(page).to have_link("CA du Pays Basque")
  end

  it "updates an EPCI from the show page" do
    visit epci_path(pays_basque)

    expect(page).to have_selector("h1", text: "CA Pays Basque")

    click_on "Modifier", match: :first

    expect(page).to have_selector("[role=dialog]", text: "Modification de l'EPCI")

    fill_in "Nom de l'EPCI", with: "CA du Pays Basque"
    click_on "Enregistrer"

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")

    expect(page).to have_selector("h1", text: "CA du Pays Basque")
  end
end
