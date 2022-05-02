# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Departements", type: :system do
  let!(:nord) { create(:departement, name: "Nord") }

  it "visits index & show pages" do
    visit departements_path

    expect(page).to have_selector("h1", text: "Départements")
    expect(page).to have_link("Nord")

    click_on "Nord"

    expect(page).to have_current_path(%r{^/departements/#{nord.id}})
    expect(page).to have_selector("h1", text: "Nord")
  end

  it "updates a departement from index page" do
    visit departements_path

    expect(page).to have_selector("h1", text: "Départements")
    expect(page).to have_link("Nord")

    click_on "Modifier ce département", match: :first

    expect(page).to have_selector("[role=dialog]", text: "Modification du département")

    fill_in "Nom du département", with: "Département du Nord"
    click_on "Enregistrer"

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")

    expect(page).to have_selector("h1", text: "Départements")
    expect(page).to have_link("Département du Nord")
  end

  it "updates a departement from the show page" do
    visit departement_path(nord)

    expect(page).to have_selector("h1", text: "Nord")

    click_on "Modifier"

    expect(page).to have_selector("[role=dialog]", text: "Modification du département")

    fill_in "Nom du département", with: "Département du Nord"
    click_on "Enregistrer"

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")

    expect(page).to have_selector("h1", text: "Département du Nord")
  end
end
