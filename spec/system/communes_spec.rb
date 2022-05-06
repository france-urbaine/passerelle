# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Communes", type: :system, use_fixtures: true do
  fixtures :communes, :epcis, :departements, :regions

  it "visits index & show pages" do
    visit communes_path

    expect(page).to have_selector("h1", text: "Communes")
    expect(page).to have_link("Bayonne")

    click_on "Bayonne"

    expect(page).to have_current_path(%r{^/communes/.{36}})
    expect(page).to have_selector("h1", text: "Bayonne")
  end

  it "updates a commune from index page" do
    visit communes_path

    expect(page).to have_selector("h1", text: "Communes")
    expect(page).to have_link("Bayonne")

    within "tr", text: "Bayonne" do
      click_on "Modifier cette commune"
    end

    expect(page).to have_selector("[role=dialog]", text: "Modification de la commune")
    expect(page).to have_field("Nom de la commune", with: "Bayonne")

    within "[role=dialog]" do
      fill_in  "Nom de la commune", with: "Bayonne-Anglet-Biarritz"
      click_on "Enregistrer"
    end

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")

    expect(page).to have_selector("h1", text: "Communes")
    expect(page).to have_link("Bayonne-Anglet-Biarritz")
  end

  it "updates a commune from the show page" do
    visit commune_path(communes(:bayonne))

    expect(page).to have_selector("h1", text: "Bayonne")
    expect(page).to have_link("Modifier")

    click_on "Modifier"

    expect(page).to have_selector("[role=dialog]", text: "Modification de la commune")
    expect(page).to have_field("Nom de la commune", with: "Bayonne")

    within "[role=dialog]" do
      fill_in  "Nom de la commune", with: "Bayonne-Anglet-Biarritz"
      click_on "Enregistrer"
    end

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")

    expect(page).to have_selector("h1", text: "Bayonne-Anglet-Biarritz")
  end
end
