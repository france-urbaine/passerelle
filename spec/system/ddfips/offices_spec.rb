# frozen_string_literal: true

require "system_helper"

RSpec.describe "DDFIP offices" do
  fixtures :regions, :departements
  fixtures :ddfips, :offices, :users

  let(:ddfip64)      { ddfips(:pyrenees_atlantiques) }
  let(:pelp_bayonne) { offices(:pelp_bayonne) }

  before { sign_in(users(:marc)) }

  it "visits an office page from the DDFIP page" do
    visit ddfip_path(ddfip64)

    # A table of offices should be present
    #
    expect(page).to have_selector("h1", text: "DDFIP des Pyrénées-Atlantiques")
    expect(page).to have_selector(:table_row, "Guichet" => "PELP de Bayonne")
    expect(page).to have_selector(:table_row, "Guichet" => "PELH de Bayonne")
    expect(page).to have_selector(:table_row, "Guichet" => "SIP de Bayonne")

    click_on "PELP de Bayonne"

    # The browser should visit the user page
    #
    expect(page).to have_current_path(office_path(pelp_bayonne))
    expect(page).to have_selector("h1", text: "PELP de Bayonne")

    go_back

    # The browser should have redirect back to the DDFIP page
    #
    expect(page).to have_current_path(ddfip_path(ddfip64))
    expect(page).to have_selector("h1", text: "DDFIP des Pyrénées-Atlantiques")
  end

  it "paginate offices on the DDFIP page" do
    # Create enough offices to have several pages
    #
    create_list(:office, 10, ddfip: ddfip64)

    visit ddfip_path(ddfip64)

    expect(page).to     have_text("13 guichets | Page 1 sur 2")
    expect(page).not_to have_button("Options d'affichage")
  end

  it "creates an office from the DDFIP page" do
    visit ddfip_path(ddfip64)

    # A button should be present to add a new office
    #
    click_on "Ajouter un guichet"

    # A dialog box should appear with a form to fill
    #
    within "[role=dialog]", text: "Création d'un nouveau guichet" do |dialog|
      expect(dialog).not_to have_field("DDFIP")

      expect(dialog).to have_field("Nom du guichet", with: nil)
      expect(dialog).to have_select("Action",        selected: "Veuillez sélectionner")

      fill_in "Nom du guichet", with: "SIP de Pau"
      select "Occupation de locaux d'habitation", from: "Action"

      click_on "Enregistrer"
    end

    # The browser should stay on the DDFIP page
    # The new office should appear
    #
    expect(page).to  have_current_path(ddfip_path(ddfip64))
    expect(page).to  have_selector("h1", text: "DDFIP des Pyrénées-Atlantiques")
    expect(page).to have_selector(:table_row, "Guichet" => "SIP de Pau")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Un nouveau guichet a été ajouté avec succés.")
  end

  it "updates an office from the DDFIP page" do
    visit ddfip_path(ddfip64)

    # A button should be present to edit the office
    #
    within :table_row, { "Guichet" => "PELP de Bayonne" } do
      click_on "Modifier ce guichet"
    end

    # A dialog box should appear with a form
    # The form should be filled with office data
    #
    within "[role=dialog]", text: "Modification du guichet" do |dialog|
      expect(dialog).to have_field("DDFIP",          with: "DDFIP des Pyrénées-Atlantiques")
      expect(dialog).to have_field("Nom du guichet", with: "PELP de Bayonne")
      expect(dialog).to have_select("Action",        selected: "Évaluation de locaux professionnels")

      fill_in "Nom du guichet", with: "PELP de Bayonne-Anglet-Biarritz"
      click_on "Enregistrer"
    end

    # The browser should stay on the DDFIP page
    # The office should have changed its name
    #
    expect(page).to have_current_path(ddfip_path(ddfip64))
    expect(page).to have_selector("h1", text: "DDFIP des Pyrénées-Atlantiques")
    expect(page).to have_selector(:table_row, "Guichet" => "PELP de Bayonne-Anglet-Biarritz")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "discards an office from the DDFIP page & rollbacks" do
    visit ddfip_path(ddfip64)

    expect(page).to have_text("3 guichets | Page 1 sur 1")

    # A button should be present to remove the office
    #
    within :table_row, { "Guichet" => "PELP de Bayonne" } do
      click_on "Supprimer ce guichet"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer ce guichet ?" do
      click_on "Continuer"
    end

    # The browser should stay on the DDFIP page
    # The office should not appears anymore
    #
    expect(page).to     have_current_path(ddfip_path(ddfip64))
    expect(page).to     have_selector("h1", text: "DDFIP des Pyrénées-Atlantiques")
    expect(page).to     have_text("2 guichets | Page 1 sur 1")
    expect(page).not_to have_selector(:table_row, "Guichet" => "PELP de Bayonne")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Le guichet a été supprimé.")

    # The notification should include a button to cancel the last action
    #
    within "[role=alert]", text: "Le guichet a été supprimé." do
      click_on "Annuler"
    end

    # The browser should stay on the DDFIP page
    # The office should be back again
    #
    expect(page).to have_current_path(ddfip_path(ddfip64))
    expect(page).to have_selector("h1", text: "DDFIP des Pyrénées-Atlantiques")
    expect(page).to have_text("3 guichets | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "Guichet" => "PELP de Bayonne")

    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector("[role=alert]", text: "Le guichet a été supprimé.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression du guichet a été annulée.")
  end

  it "selects and discards one office from the DDFIP page & rollbacks" do
    visit ddfip_path(ddfip64)

    expect(page).to have_text("3 guichets | Page 1 sur 1")

    # Checkboxes should be present to select offices
    #
    within :table_row, { "Guichet" => "PELP de Bayonne" } do
      check
    end

    # A message should diplay the number of selected offices
    # with a button to remove them
    #
    within ".header-bar--selection", text: "1 guichet sélectionné" do
      click_on "Tout supprimer"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer le guichet sélectionné ?" do
      click_on "Continuer"
    end

    # The browser should stay on index page
    # The selected offices should not appears anymore
    # Other offices should remain
    #
    expect(page).to     have_current_path(ddfip_path(ddfip64))
    expect(page).to     have_selector("h1", text: "DDFIP des Pyrénées-Atlantiques")
    expect(page).to     have_text("2 guichets | Page 1 sur 1")
    expect(page).not_to have_selector(:table_row, "Guichet" => "PELP de Bayonne")
    expect(page).to     have_selector(:table_row, "Guichet" => "PELH de Bayonne")
    expect(page).to     have_selector(:table_row, "Guichet" => "SIP de Bayonne")

    # The selection message should not appears anymore
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les guichets sélectionnés ont été supprimés.")

    # The notification should include a button to cancel the last action
    #
    within "[role=alert]", text: "Les guichets sélectionnés ont été supprimés." do
      click_on "Annuler"
    end

    # The browser should stay on index page
    # The remove offices should be back again
    #
    expect(page).to have_current_path(ddfip_path(ddfip64))
    expect(page).to have_selector("h1", text: "DDFIP des Pyrénées-Atlantiques")
    expect(page).to have_text("3 guichets | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "Guichet" => "PELP de Bayonne")

    # The selection message should not appears again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=alert]", text: "Les guichets sélectionnés ont été supprimés.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression des guichets sélectionnés a été annulée.")
  end

  it "selects and discards all offices from the current page on index page & rollbacks" do
    # Create a bunch of offices to have several pages
    # Create discarded offices to verify they are not rollbacked
    #
    create_list(:office, 10, ddfip: ddfip64)
    create_list(:office, 5, :discarded, ddfip: ddfip64)

    visit ddfip_path(ddfip64)

    expect(page).to have_text("13 guichets | Page 1 sur 2")

    # Checkboxes should be present to select all offices
    #
    within "#datatable-offices" do
      check nil, match: :first
    end

    # A message should diplay the number of selected offices
    # with a button to remove them
    #
    within ".header-bar--selection", text: "10 guichets sélectionnés" do
      click_on "Tout supprimer"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer les 10 guichets sélectionnés ?" do
      click_on "Continuer"
    end

    # The browser should stay on index page
    # The selected offices should have been removed
    #
    expect(page).to     have_current_path(ddfip_path(ddfip64))
    expect(page).to     have_selector("h1", text: "DDFIP des Pyrénées-Atlantiques")
    expect(page).to     have_text("3 guichets | Page 1 sur 1")
    expect(page).not_to have_selector(:table_row, "Guichet" => "PELP de Bayonne")
    expect(page).not_to have_selector(:table_row, "Guichet" => "PELH de Bayonne")
    expect(page).not_to have_selector(:table_row, "Guichet" => "SIP de Bayonne")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les guichets sélectionnés ont été supprimés.")

    # The notification should include a button to cancel the last action
    #
    within "[role=alert]", text: "Les guichets sélectionnés ont été supprimés." do
      click_on "Annuler"
    end

    # The browser should stay on index page
    # All offices should be back again
    #
    expect(page).to have_current_path(ddfip_path(ddfip64))
    expect(page).to have_selector("h1", text: "DDFIP des Pyrénées-Atlantiques")
    expect(page).to have_text("3 guichets | Page 1 sur 2")
    expect(page).to have_selector(:table_row, "Guichet" => "PELP de Bayonne")
    expect(page).to have_selector(:table_row, "Guichet" => "PELH de Bayonne")
    expect(page).to have_selector(:table_row, "Guichet" => "SIP de Bayonne")

    # The selection message should not appears again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=alert]", text: "Les guichets sélectionnés ont été supprimés.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression des guichets sélectionnés a été annulée.")
  end

  it "selects and discards all offices through several pages on index page & rollbacks" do
    # Create a bunch of offices to have several pages
    # TODO: Create discarded offices to verify they are not rollbacked
    #
    create_list(:office, 10, ddfip: ddfip64)

    visit ddfip_path(ddfip64)

    expect(page).to have_text("13 guichets | Page 1 sur 2")

    # Checkboxes should be present to select all offices
    #
    within "#datatable-offices" do
      check nil, match: :first
    end

    # A message should diplay the number of selected offices
    # A link to select any offices from any page should be present
    # A link to remove all of them should be present
    #
    within ".header-bar--selection", text: "10 guichets sélectionnés" do
      click_on "Sélectionner les 13 guichets des 2 pages"
    end

    within ".header-bar--selection", text: "13 guichets sélectionnés" do
      click_on "Tout supprimer"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer les 13 guichets sélectionnés ?" do
      click_on "Continuer"
    end

    # The browser should stay on index page
    # No offices should appear anymore
    #
    expect(page).to have_current_path(ddfip_path(ddfip64))
    expect(page).to have_selector("h1", text: "DDFIP des Pyrénées-Atlantiques")
    expect(page).to have_text("Aucun guichet disponible.")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les guichets sélectionnés ont été supprimés.")

    # The notification should include a button to cancel the last action
    #
    within "[role=alert]", text: "Les guichets sélectionnés ont été supprimés." do
      click_on "Annuler"
    end

    # The browser should stay on index page
    # All offices should be back again
    #
    expect(page).to have_current_path(ddfip_path(ddfip64))
    expect(page).to have_selector("h1", text: "DDFIP des Pyrénées-Atlantiques")
    expect(page).to have_text("3 guichets | Page 1 sur 2")
    expect(page).to have_selector(:table_row, "Guichet" => "PELP de Bayonne")
    expect(page).to have_selector(:table_row, "Guichet" => "PELH de Bayonne")
    expect(page).to have_selector(:table_row, "Guichet" => "SIP de Bayonne")

    # The selection message should not appears again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=alert]", text: "Les guichets sélectionnés ont été supprimés.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression des guichets sélectionnés a été annulée.")
  end
end
