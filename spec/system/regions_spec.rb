# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Regions", type: :system do
  let!(:aquitaine) { create(:region, name: "Aquitaine") }

  it "visits index & show pages" do
    visit regions_path

    expect(page).to have_selector("h1", text: "Base de données des régions")
    expect(page).to have_link("Aquitaine")

    click_on "Aquitaine"

    expect(page).to have_current_path(%r{^/regions/#{aquitaine.id}})
    expect(page).to have_selector("h1", text: "Aquitaine")
  end

  it "updates a region from index page" do
    visit regions_path

    expect(page).to have_selector("h1", text: "Base de données des régions")
    expect(page).to have_link("Aquitaine")

    click_on "Modifier cette région", match: :first
    expect(page).to have_selector("[role=dialog]", text: "Modification de la région")

    fill_in "Nom de la région", with: "Nouvelle Aquitaine"
    click_on "Enregistrer"

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")

    expect(page).to have_selector("h1", text: "Base de données des régions")
    expect(page).to have_link("Nouvelle Aquitaine")
  end

  it "updates a region from the show page" do
    visit region_path(aquitaine)
    expect(page).to have_selector("h1", text: "Aquitaine")

    click_on "Modifier"
    expect(page).to have_selector("[role=dialog]", text: "Modification de la région")

    fill_in "Nom de la région", with: "Nouvelle Aquitaine"
    click_on "Enregistrer"

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")

    expect(page).to have_selector("h1", text: "Nouvelle Aquitaine")
  end
end
