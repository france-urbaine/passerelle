# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Communes", type: :system do
  let!(:biarritz) { create(:commune, name: "Biarritz") }

  it "visits index & show pages" do
    visit communes_path

    expect(page).to have_selector("h1", text: "Base de données des communes")
    expect(page).to have_link("Biarritz")

    click_on "Biarritz"

    expect(page).to have_current_path(%r{^/communes/#{biarritz.id}})
    expect(page).to have_selector("h1", text: "Biarritz")
  end

  it "updates a commune from index page" do
    visit communes_path

    expect(page).to have_selector("h1", text: "Base de données des communes")
    expect(page).to have_link("Biarritz")

    click_on "Modifier cette commune", match: :first

    expect(page).to have_selector("[role=dialog]", text: "Modification de la commune")

    fill_in "Nom de la commune", with: "Biarritz-Anglet"
    click_on "Enregistrer"

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")

    expect(page).to have_selector("h1", text: "Base de données des communes")
    expect(page).to have_link("Biarritz-Anglet")
  end

  it "updates a commune from the show page" do
    visit commune_path(biarritz)

    expect(page).to have_selector("h1", text: "Biarritz")

    click_on "Modifier"

    expect(page).to have_selector("[role=dialog]", text: "Modification de la commune")

    fill_in "Nom de la commune", with: "Biarritz-Anglet"
    click_on "Enregistrer"

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")

    expect(page).to have_selector("h1", text: "Biarritz-Anglet")
  end
end
