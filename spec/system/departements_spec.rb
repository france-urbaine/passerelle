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
    visit departements_path

    expect(page).to have_selector("h1", text: "Départements")
    expect(page).to have_link("Nord")

    click_on "Nord"

    expect(page).to have_selector("h1", text: "Nord")
    expect(page).to have_current_path(departement_path(nord))
  end

  it "visits links from the show page & comes back" do
    visit departement_path(nord)

    expect(page).to have_selector("h1", text: "Nord")
    expect(page).to have_link("Hauts-de-France")
    expect(page).to have_link("Voir les EPCIs")
    expect(page).to have_link("Voir les communes")
    expect(page).to have_link("DDFIP du Nord")

    click_on "Hauts-de-France"

    expect(page).to have_selector("h1", text: "Hauts-de-France")
    expect(page).to have_current_path(region_path(hauts_de_france))

    go_back

    expect(page).to have_selector("h1", text: "Nord")
    expect(page).to have_current_path(departement_path(nord))

    click_on "Voir les EPCIs"

    expect(page).to have_selector("h1", text: "EPCI")
    expect(page).to have_selector("tr", text: "Métropole Européenne de Lille")
    expect(page).to have_current_path(epcis_path(search: "59"))

    go_back

    expect(page).to have_selector("h1", text: "Nord")
    expect(page).to have_current_path(departement_path(nord))

    click_on "Voir les communes"

    expect(page).to have_selector("h1", text: "Communes")
    expect(page).to have_selector("tr", text: "Lille")
    expect(page).to have_current_path(communes_path(search: "59"))

    go_back

    expect(page).to have_selector("h1", text: "Nord")
    expect(page).to have_current_path(departement_path(nord))

    click_on "DDFIP du Nord"

    expect(page).to have_selector("h1", text: "DDFIP du Nord")
    expect(page).to have_current_path(ddfip_path(ddfip59))

    go_back

    expect(page).to have_selector("h1", text: "Nord")
    expect(page).to have_current_path(departement_path(nord))
  end

  it "updates a departement from the index page" do
    visit departements_path

    # A button should be present to edit the collectivity
    #
    within "tr", text: "Nord" do |row|
      expect(row).to have_link("Modifier ce département", class: "icon-button")

      click_on "Modifier ce département"
    end

    # A dialog box should appear with a form
    # The form should be filled with collectivity data
    #
    expect(page).to have_selector("[role=dialog]", text: "Modification du département")

    within "[role=dialog]" do
      expect(page).to have_field("Nom du département",        with: "Nord")
      expect(page).to have_field("Code INSEE du département", with: "59")
      expect(page).to have_field("Région",                    with: "Hauts-de-France")

      fill_in  "Nom du département", with: "Département du Nord"
      click_on "Enregistrer"
    end

    # The browser should stay on index page
    # The collectivity should have changed its name
    #
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to     have_current_path(departements_path)
    expect(page).to     have_selector("h1", text: "Départements")
    expect(page).to     have_selector("tr", text: "Département du Nord")

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "updates a departement from the show page" do
    visit departement_path(nord)

    # A button should be present to edit the collectivity
    #
    within ".header-bar" do |header|
      expect(header).to have_selector("h1", text: "Nord")
      expect(header).to have_link("Modifier", class: "button")

      click_on "Modifier"
    end

    # A dialog box should appear with a form
    # The form should be filled with collectivity data
    #
    expect(page).to have_selector("[role=dialog]", text: "Modification du département")

    within "[role=dialog]" do
      expect(page).to have_field("Nom du département",        with: "Nord")
      expect(page).to have_field("Code INSEE du département", with: "59")
      expect(page).to have_field("Région",                    with: "Hauts-de-France")

      fill_in  "Nom du département", with: "Département du Nord"
      click_on "Enregistrer"
    end

    # The browser should stay on show page
    # The collectivity should have changed its name
    #
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to     have_current_path(departement_path(nord))
    expect(page).to     have_selector("h1", text: "Département du Nord")

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")
  end
end
