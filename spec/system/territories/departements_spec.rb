# frozen_string_literal: true

require "system_helper"

RSpec.describe "Departements" do
  fixtures :regions, :departements, :epcis, :communes
  fixtures :ddfips, :users

  let(:nord)            { departements(:nord) }
  let(:hauts_de_france) { regions(:hauts_de_france) }
  let(:ddfip59)         { ddfips(:nord) }

  before { sign_in(users(:marc)) }

  it "visits index & show pages" do
    visit territories_departements_path

    # A table of all departements should be present
    #
    expect(page).to have_selector("h1", text: "Départements")
    expect(page).to have_selector("tr", text: "Pyrénées-Atlantiques")
    expect(page).to have_selector("tr", text: "Nord")

    click_on "Nord"

    # The browser should visit the departement page
    #
    expect(page).to have_current_path(territories_departement_path(nord))
    expect(page).to have_selector("h1", text: "Nord")

    go_back

    # The browser should redirect back to the index page
    #
    expect(page).to have_current_path(territories_departements_path)
    expect(page).to have_selector("h1", text: "Départements")
  end

  it "visits links on a departement page & comes back" do
    visit territories_departement_path(nord)

    # On the collectivity page, we expect:
    # - a link to the region
    #
    expect(page).to have_selector("h1", text: "Nord")
    expect(page).to have_link("Hauts-de-France")

    click_on "Hauts-de-France"

    # The browser should visit the region page
    #
    expect(page).to have_current_path(territories_region_path(hauts_de_france))
    expect(page).to have_selector("h1", text: "Hauts-de-France")

    go_back

    # The browser should redirect back to the departement page
    #
    expect(page).to have_current_path(territories_departement_path(nord))
    expect(page).to have_selector("h1", text: "Nord")
  end

  it "updates a departement from the index page" do
    visit territories_departements_path

    # A button should be present to edit the collectivity
    #
    within "tr", text: "Nord" do
      click_on "Modifier ce département"
    end

    # A dialog box should appear with a form
    # The form should be filled with collectivity data
    #
    within "[role=dialog]", text: "Modification du département" do |dialog|
      expect(dialog).to have_field("Nom du département",        with: "Nord")
      expect(dialog).to have_field("Code INSEE du département", with: "59")
      expect(dialog).to have_field("Région",                    with: "Hauts-de-France")

      fill_in  "Nom du département", with: "Département du Nord"
      click_on "Enregistrer"
    end

    # The browser should stay on index page
    # The collectivity should have changed its name
    #
    expect(page).to have_current_path(territories_departements_path)
    expect(page).to have_selector("h1", text: "Départements")
    expect(page).to have_selector("tr", text: "Département du Nord")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=log]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "updates a departement from the departement page" do
    visit territories_departement_path(nord)

    # A button should be present to edit the collectivity
    #
    within ".breadcrumbs", text: "Nord" do
      click_on "Modifier"
    end

    # A dialog box should appear with a form
    # The form should be filled with collectivity data
    #
    within "[role=dialog]", text: "Modification du département" do |dialog|
      expect(dialog).to have_field("Nom du département",        with: "Nord")
      expect(dialog).to have_field("Code INSEE du département", with: "59")
      expect(dialog).to have_field("Région",                    with: "Hauts-de-France")

      fill_in  "Nom du département", with: "Département du Nord"
      click_on "Enregistrer"
    end

    # The browser should stay on show page
    # The collectivity should have changed its name
    #
    expect(page).to have_current_path(territories_departement_path(nord))
    expect(page).to have_selector("h1", text: "Département du Nord")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=log]", text: "Les modifications ont été enregistrées avec succés.")
  end
end
