# frozen_string_literal: true

require "system_helper"

RSpec.describe "DGFIPs in admin" do
  fixtures :dgfips, :users

  let(:dgfip) { dgfips(:dgfip) }

  before { sign_in(users(:marc)) }

  it "creates a DGFIP if no DGFIPs are available" do
    DGFIP.discard_all

    visit admin_dgfip_path

    # A button should be present to add a new DGFIP
    #
    click_on "Créer une DGFIP"

    # A dialog box should appear with a form to fill
    #
    within "[role=dialog]", text: "Création d'une nouvelle DGFIP" do |dialog|
      expect(dialog).to have_field("Nom de la DGFIP")

      fill_in "Nom de la DGFIP", with: "DGFIP test"

      click_on "Enregistrer"
    end

    # The browser should go on the DGFIP page
    # The new DGFIP should appear
    #
    expect(page).to have_current_path(admin_dgfip_path)
    expect(page).to have_selector("h1", text: "DGFIP test")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Une nouvelle DGFIP a été ajoutée avec succés.")
  end

  it "updates a DGFIP from the DGFIP page" do
    visit admin_dgfip_path

    # A button should be present to edit the DGFIP
    #
    within ".header-bar", text: "Direction générale des Finances publiques" do
      click_on "Modifier"
    end

    # A dialog box should appear with a form
    # The form should be filled with DGFIP data
    #
    within "[role=dialog]", text: "Modification de la DGFIP" do
      expect(page).to have_field("Nom de la DGFIP", with: "Direction générale des Finances publiques")

      fill_in "Nom de la DGFIP", with: "DGFIP - Direction générale des Finances publiques"
      click_on "Enregistrer"
    end

    # The browser should stay on the DGFIP page
    # The DGFIP should have changed its name
    #
    expect(page).to have_current_path(admin_dgfip_path(dgfip))
    expect(page).to have_selector("h1", text: "DGFIP - Direction générale des Finances publiques")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")
  end
end
