# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Departements", type: :system, use_fixtures: true do
  fixtures :departements, :regions

  it "visits index & show pages" do
    visit departements_path

    expect(page).to have_selector("h1", text: "Départements")
    expect(page).to have_link("Nord")

    click_on "Nord"

    expect(page).to have_current_path(%r{^/departements/.{36}})
    expect(page).to have_selector("h1", text: "Nord")
  end

  it "updates a departement from index page" do
    visit departements_path

    expect(page).to have_selector("h1", text: "Départements")
    expect(page).to have_link("Nord")

    within "tr", text: "Nord" do
      click_on "Modifier ce département"
    end

    expect(page).to have_selector("[role=dialog]", text: "Modification du département")
    expect(page).to have_field("Nom du département", with: "Nord")

    within "[role=dialog]" do
      fill_in  "Nom du département", with: "Département du Nord"
      click_on "Enregistrer"
    end

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")

    expect(page).to have_selector("h1", text: "Départements")
    expect(page).to have_link("Département du Nord")
  end

  it "updates a departement from the show page" do
    visit departement_path(departements(:nord))

    expect(page).to have_selector("h1", text: "Nord")
    expect(page).to have_link("Modifier")

    click_on "Modifier"

    expect(page).to have_selector("[role=dialog]", text: "Modification du département")
    expect(page).to have_field("Nom du département", with: "Nord")

    within "[role=dialog]" do
      fill_in  "Nom du département", with: "Département du Nord"
      click_on "Enregistrer"
    end

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")

    expect(page).to have_selector("h1", text: "Département du Nord")
  end
end
