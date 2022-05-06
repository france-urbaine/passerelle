# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Regions", type: :system, use_fixtures: true do
  fixtures :regions

  it "visits index & show pages" do
    visit regions_path

    expect(page).to have_selector("h1", text: "Régions")
    expect(page).to have_link("Nouvelle-Aquitaine")

    click_on "Nouvelle-Aquitaine"

    expect(page).to have_current_path(%r{^/regions/.{36}})
    expect(page).to have_selector("h1", text: "Nouvelle-Aquitaine")
  end

  it "updates a region from index page" do
    visit regions_path

    expect(page).to have_selector("h1", text: "Régions")
    expect(page).to have_link("Nouvelle-Aquitaine")

    within "tr", text: "Nouvelle-Aquitaine" do
      click_on "Modifier cette région"
    end

    expect(page).to have_selector("[role=dialog]", text: "Modification de la région")
    expect(page).to have_field("Nom de la région", with: "Nouvelle-Aquitaine")

    within "[role=dialog]" do
      fill_in  "Nom de la région", with: "Nouvelle Aquitaine"
      click_on "Enregistrer"
    end

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")

    expect(page).to have_selector("h1", text: "Régions")
    expect(page).to have_link("Nouvelle Aquitaine")
  end

  it "updates a region from the show page" do
    visit region_path(regions(:nouvelle_aquitaine))

    expect(page).to have_selector("h1", text: "Nouvelle-Aquitaine")
    expect(page).to have_link("Modifier")

    click_on "Modifier"

    expect(page).to have_selector("[role=dialog]", text: "Modification de la région")
    expect(page).to have_field("Nom de la région", with: "Nouvelle-Aquitaine")

    within "[role=dialog]" do
      fill_in  "Nom de la région", with: "Nouvelle Aquitaine"
      click_on "Enregistrer"
    end

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")

    expect(page).to have_selector("h1", text: "Nouvelle Aquitaine")
  end
end
