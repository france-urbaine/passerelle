# frozen_string_literal: true

require "system_helper"

RSpec.describe "DGFIPs in admin" do
  fixtures :dgfips, :users, :audits

  let(:dgfip) { dgfips(:dgfip) }

  before { sign_in(users(:marc)) }

  it "visits the DGFIP page" do
    visit admin_dgfip_path

    # On the DGFIP page, we expect to get the title of the organization
    #
    expect(page).to have_selector("h1", text: "Direction générale des Finances publiques")
  end

  it "visits the the page of a newly created DGFIP when no record are available" do
    DGFIP.delete_all

    visit admin_dgfip_path

    # On the DGFIP page, we expect to get the title of the organization
    #
    expect(page).to have_selector("h1", text: "Direction générale des Finances publiques")
  end

  it "visits DGFIP & audits pages" do
    visit admin_dgfip_path

    dgfip.update!(name: "Direction Générale des FInances Publiques")

    # The browser should visit the dgfip page
    #
    expect(page).to have_selector("a.button", text: "Voir toute l'activité")

    click_on "Voir toute l'activité"

    # The browser should visit the dgfip audits page
    #
    expect(page).to have_current_path(admin_dgfip_audits_path)
    expect(page).to have_selector("pre.logs")
  end

  it "updates the DGFIP" do
    visit admin_dgfip_path

    # A button should be present to edit the DGFIP
    #
    within ".breadcrumbs", text: "Direction générale des Finances publiques" do
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
    expect(page).to have_no_selector("[role=dialog]")
    expect(page).to have_selector("[role=log]", text: "Les modifications ont été enregistrées avec succés.")
  end
end
