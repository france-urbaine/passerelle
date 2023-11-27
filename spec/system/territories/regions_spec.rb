# frozen_string_literal: true

require "system_helper"

RSpec.describe "Regions" do
  fixtures :regions, :departements, :epcis, :communes
  fixtures :ddfips, :users

  let(:nouvelle_aquitaine)   { regions(:nouvelle_aquitaine) }
  let(:pyrenees_atlantiques) { departements(:pyrenees_atlantiques) }
  let(:ddfip64)              { ddfips(:pyrenees_atlantiques) }

  before { sign_in(users(:marc)) }

  it "visits index & region pages" do
    visit territories_regions_path

    # A table of all regions should be present
    #
    expect(page).to have_selector("h1", text: "Régions")
    expect(page).to have_link("Nouvelle-Aquitaine")
    expect(page).to have_link("Ile-de-France")

    click_on "Nouvelle-Aquitaine"

    # The browser should visit the region page
    #
    expect(page).to have_current_path(territories_region_path(nouvelle_aquitaine))
    expect(page).to have_selector("h1", text: "Nouvelle-Aquitaine")

    go_back

    # The browser should redirect back to the index page
    #
    expect(page).to have_current_path(territories_regions_path)
    expect(page).to have_selector("h1", text: "Régions")
  end

  it "updates a region from the index page" do
    visit territories_regions_path

    # A button should be present to edit the collectivity
    #
    within "tr", text: "Nouvelle-Aquitaine" do
      click_on "Modifier cette région"
    end

    # A dialog box should appear with a form
    # The form should be filled with collectivity data
    #
    within "[role=dialog]", text: "Modification de la région" do |dialog|
      expect(dialog).to have_field("Nom de la région",        with: "Nouvelle-Aquitaine")
      expect(dialog).to have_field("Code INSEE de la région", with: "75")

      fill_in  "Nom de la région", with: "Nouvelle Aquitaine indépendante !"
      click_on "Enregistrer"
    end

    # The browser should stay on index page
    # The collectivity should have changed its name
    #
    expect(page).to have_current_path(territories_regions_path)
    expect(page).to have_selector("h1", text: "Régions")
    expect(page).to have_selector("tr", text: "Nouvelle Aquitaine indépendante !")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=log]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "updates a region from the show page" do
    visit territories_region_path(nouvelle_aquitaine)

    # A button should be present to edit the collectivity
    #
    within ".breadcrumbs", text: "Nouvelle-Aquitaine" do
      click_on "Modifier"
    end

    # A dialog box should appear with a form
    # The form should be filled with collectivity data
    #
    within "[role=dialog]", text: "Modification de la région" do |dialog|
      expect(dialog).to have_field("Nom de la région", with: "Nouvelle-Aquitaine")
      expect(dialog).to have_field("Code INSEE de la région", with: "75")

      fill_in  "Nom de la région", with: "Nouvelle Aquitaine indépendante !"
      click_on "Enregistrer"
    end

    # The browser should stay on show page
    # The collectivity should have changed its name
    #
    expect(page).to have_current_path(territories_region_path(nouvelle_aquitaine))
    expect(page).to have_selector("h1", text: "Nouvelle Aquitaine indépendante !")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=log]", text: "Les modifications ont été enregistrées avec succés.")
  end
end
