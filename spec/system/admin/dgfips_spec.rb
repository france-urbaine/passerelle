# frozen_string_literal: true

require "system_helper"

RSpec.describe "DGFIPs in admin" do
  fixtures :dgfips, :users

  let(:ministere) { dgfips(:ministere) }

  before { sign_in(users(:marc)) }

  it "visits index & DGFIP pages" do
    visit admin_dgfips_path

    # A table of all DGFIPs should be present
    #
    expect(page).to have_selector("h1", text: "DGFIP")
    expect(page).to have_link("Ministère de l'Économie et des Finances")
    expect(page).to have_link("Direction nationale d'Enquêtes fiscales")
    expect(page).to have_link("Direction des Vérifications nationales et internationales")

    click_on "Ministère de l'Économie et des Finances"

    # The browser should visit the DGFIP page
    #
    expect(page).to have_current_path(admin_dgfip_path(ministere))
    expect(page).to have_selector("h1", text: "Ministère de l'Économie et des Finances")

    go_back

    # The browser should redirect back to the index page
    #
    expect(page).to have_current_path(admin_dgfips_path)
    expect(page).to have_selector("h1", text: "DGFIP")
  end

  it "creates a DGFIP from the index page" do
    visit admin_dgfips_path

    # A button should be present to add a new DGFIP
    #
    click_on "Ajouter une DGFIP"

    # A dialog box should appear with a form to fill
    #
    within "[role=dialog]", text: "Création d'une nouvelle DGFIP" do |dialog|
      expect(dialog).to have_field("Nom de la DGFIP")

      fill_in "Nom de la DGFIP", with: "DGFIP test"

      click_on "Enregistrer"
    end

    # The browser should stay on the index page
    # The new DGFIP should appear
    #
    expect(page).to have_current_path(admin_dgfips_path)
    expect(page).to have_selector("h1", text: "DGFIP")
    expect(page).to have_selector(:table_row, "DGFIP" => "DGFIP test")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Une nouvelle DGFIP a été ajoutée avec succés.")
  end

  it "updates a DGFIP from the index page" do
    visit admin_dgfips_path

    # A button should be present to edit the DGFIP
    #
    within :table_row, { "DGFIP" => "Ministère de l'Économie et des Finances" } do
      click_on "Modifier cette DGFIP"
    end

    # A dialog box should appear with a form
    # The form should be filled with DGFIP data
    #
    within "[role=dialog]", text: "Modification de la DGFIP" do |dialog|
      expect(dialog).to have_field("Nom de la DGFIP", with: "Ministère de l'Économie et des Finances")

      fill_in "Nom de la DGFIP", with: "Ministère de l'Économie et des Finances (modifié)"
      click_on "Enregistrer"
    end

    # The browser should stay on the index page
    # The DGFIP should have changed its name
    #
    expect(page).to have_current_path(admin_dgfips_path)
    expect(page).to have_selector("h1", text: "DGFIP")
    expect(page).to have_selector(:table_row, "DGFIP" => "Ministère de l'Économie et des Finances (modifié)")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "updates a DGFIP from the DGFIP page" do
    visit admin_dgfip_path(ministere)

    # A button should be present to edit the DGFIP
    #
    within ".header-bar", text: "Ministère de l'Économie et des Finances" do
      click_on "Modifier"
    end

    # A dialog box should appear with a form
    # The form should be filled with DGFIP data
    #
    within "[role=dialog]", text: "Modification de la DGFIP" do
      expect(page).to have_field("Nom de la DGFIP", with: "Ministère de l'Économie et des Finances")

      fill_in "Nom de la DGFIP", with: "DGFIP - Ministère de l'Économie et des Finances"
      click_on "Enregistrer"
    end

    # The browser should stay on the DGFIP page
    # The DGFIP should have changed its name
    #
    expect(page).to have_current_path(admin_dgfip_path(ministere))
    expect(page).to have_selector("h1", text: "DGFIP - Ministère de l'Économie et des Finances")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "discards a DGFIP from the index page & rollbacks" do
    visit admin_dgfips_path

    expect(page).to have_text("3 DGFIPs | Page 1 sur 1")

    # A button should be present to remove the DGFIP
    #
    within :table_row, { "DGFIP" => "Ministère de l'Économie et des Finances" } do
      click_on "Supprimer cette DGFIP"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer cette DGFIP ?" do
      click_on "Continuer"
    end

    # The browser should stay on the index page
    # The DGFIP should not appears anymore
    #
    expect(page).to     have_current_path(admin_dgfips_path)
    expect(page).to     have_selector("h1", text: "DGFIP")
    expect(page).to     have_text("2 DGFIPs | Page 1 sur 1")
    expect(page).not_to have_selector(:table_row, "DGFIP" => "Ministère de l'Économie et des Finances")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "La DGFIP a été supprimée.")

    # The notification should include a button to cancel the last action
    #
    within "[role=alert]", text: "La DGFIP a été supprimée." do
      click_on "Annuler"
    end

    # The browser should stay on the index page
    # The DGFIP should be back again
    #
    expect(page).to have_current_path(admin_dgfips_path)
    expect(page).to have_selector("h1", text: "DGFIP")
    expect(page).to have_text("3 DGFIPs | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "DGFIP" => "Ministère de l'Économie et des Finances")

    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector("[role=alert]", text: "La DGFIP a été supprimée.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression de la DGFIP a été annulée.")
  end

  it "discards a DGFIP from the DGFIP page & rollbacks" do
    visit admin_dgfip_path(ministere)

    # A button should be present to remove the DGFIP
    #
    within ".header-bar", text: "Ministère de l'Économie et des Finances" do
      click_on "Supprimer"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer cette DGFIP ?" do
      click_on "Continuer"
    end

    # The browser should redirect to the index page
    # The DGFIP should not appears anymore
    #
    expect(page).to     have_current_path(admin_dgfips_path)
    expect(page).to     have_selector("h1", text: "DGFIP")
    expect(page).to     have_text("2 DGFIPs | Page 1 sur 1")
    expect(page).not_to have_selector(:table_row, "DGFIP" => "Ministère de l'Économie et des Finances")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "La DGFIP a été supprimée.")

    # The notification should include a button to cancel the last action
    #
    within "[role=alert]", text: "La DGFIP a été supprimée." do
      click_on "Annuler"
    end

    # The browser should stay on the index page
    # The DGFIP should be back again
    #
    expect(page).to have_current_path(admin_dgfips_path)
    expect(page).to have_selector("h1", text: "DGFIP")
    expect(page).to have_text("3 DGFIPs | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "DGFIP" => "Ministère de l'Économie et des Finances")

    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector("[role=alert]", text: "La DGFIP a été supprimée.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression de la DGFIP a été annulée.")
  end

  it "selects and discards one DGFIP from the index page & rollbacks" do
    visit admin_dgfips_path

    expect(page).to have_text("3 DGFIPs | Page 1 sur 1")

    # Checkboxes should be present to select DGFIPs
    #
    within :table_row, { "DGFIP" => "Ministère de l'Économie et des Finances" } do
      check
    end

    # A message should diplay the number of selected DGFIPs
    # with a button to remove them
    #
    within ".header-bar--selection", text: "1 DGFIP sélectionnée" do
      click_on "Tout supprimer"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer la DGFIP sélectionnée ?" do
      click_on "Continuer"
    end

    # The browser should stay on index page
    # The selected DGFIPs should not appears anymore
    # Other DGFIPs should remain
    #
    expect(page).to     have_current_path(admin_dgfips_path)
    expect(page).to     have_selector("h1", text: "DGFIP")
    expect(page).to     have_text("2 DGFIPs | Page 1 sur 1")
    expect(page).not_to have_selector(:table_row, "DGFIP" => "Ministère de l'Économie et des Finances")
    expect(page).to     have_selector(:table_row, "DGFIP" => "Direction nationale d'Enquêtes fiscales")
    expect(page).to     have_selector(:table_row, "DGFIP" => "Direction des Vérifications nationales et internationales")

    # The selection message should not appears anymore
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les DGFIPs sélectionnées ont été supprimées.")

    # The notification should include a button to cancel the last action
    #
    within "[role=alert]", text: "Les DGFIPs sélectionnées ont été supprimées." do
      click_on "Annuler"
    end

    # The browser should stay on index page
    # The remove DGFIPs should be back again
    #
    expect(page).to have_current_path(admin_dgfips_path)
    expect(page).to have_selector("h1", text: "DGFIP")
    expect(page).to have_text("3 DGFIPs | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "DGFIP" => "Ministère de l'Économie et des Finances")

    # The selection message should not appears again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=alert]", text: "Les DGFIPs sélectionnées ont été supprimées.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression des DGFIPs sélectionnées a été annulée.")
  end

  it "selects and discards all DGFIPs from the current page on index page & rollbacks" do
    # Create a bunch of DGFIPs to have several pages
    # Create discarded DGFIPs to verify they are not rollbacked
    #
    create_list(:dgfip, 10)
    create_list(:dgfip, 5, :discarded)

    visit admin_dgfips_path

    expect(page).to have_text("3 DGFIPs | Page 1 sur 1")

    # Paginate DGFIPs by 10
    # More than one page should exist
    #
    click_on "Options d'affichage"
    click_on "Afficher 50 lignes par page"
    click_on "Afficher 10 lignes"

    expect(page).to have_text("3 DGFIPs | Page 1 sur 2")

    # Checkboxes should be present to select all DGFIPs
    #
    within :table do
      check nil, match: :first
    end

    # A message should diplay the number of selected DGFIPs
    # with a button to remove them
    #
    within ".header-bar--selection", text: "10 DGFIPs sélectionnées" do
      click_on "Tout supprimer"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer les 10 DGFIPs sélectionnées ?" do
      click_on "Continuer"
    end

    # The browser should stay on index page
    # The selected DGFIPs should have been removed
    #
    expect(page).to     have_current_path(admin_dgfips_path)
    expect(page).to     have_selector("h1", text: "DGFIP")
    expect(page).to     have_text("3 DGFIPs | Page 1 sur 1")
    expect(page).not_to have_selector(:table_row, "DGFIP" => "Ministère de l'Économie et des Finances")
    expect(page).not_to have_selector(:table_row, "DGFIP" => "Direction nationale d'Enquêtes fiscales")
    expect(page).not_to have_selector(:table_row, "DGFIP" => "Direction des Vérifications nationales et internationales")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les DGFIPs sélectionnées ont été supprimées.")

    # The notification should include a button to cancel the last action
    #
    within "[role=alert]", text: "Les DGFIPs sélectionnées ont été supprimées." do
      click_on "Annuler"
    end

    # The browser should stay on index page
    # All DGFIPs should be back again
    #
    expect(page).to have_current_path(admin_dgfips_path)
    expect(page).to have_selector("h1", text: "DGFIP")
    expect(page).to have_text("3 DGFIPs | Page 1 sur 2")
    expect(page).to have_selector(:table_row, "DGFIP" => "Ministère de l'Économie et des Finances")
    expect(page).to have_selector(:table_row, "DGFIP" => "Direction nationale d'Enquêtes fiscales")
    expect(page).to have_selector(:table_row, "DGFIP" => "Direction des Vérifications nationales et internationales")

    # The selection message should not appears again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=alert]", text: "Les DGFIPs sélectionnées ont été supprimées.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression des DGFIPs sélectionnées a été annulée.")
  end

  it "selects and discards all DGFIPs through several pages on index page & rollbacks" do
    # Create a bunch of DGFIPs to have several pages
    # TODO: Create discarded DGFIPs to verify they are not rollbacked
    #
    create_list(:dgfip, 10)

    visit admin_dgfips_path

    expect(page).to have_text("13 DGFIPs | Page 1 sur 1")

    # Paginate DGFIPs by 10
    # More than one page should exist
    #
    click_on "Options d'affichage"
    click_on "Afficher 50 lignes par page"
    click_on "Afficher 10 lignes"

    expect(page).to have_text("13 DGFIPs | Page 1 sur 2")

    # Checkboxes should be present to select all DGFIPs
    #
    within :table do
      check nil, match: :first
    end

    # A message should diplay the number of selected DGFIPs
    # A link to select any DGFIPs from any page should be present
    # A link to remove all of them should be present
    #
    within ".header-bar--selection", text: "10 DGFIPs sélectionnées" do
      click_on "Sélectionner les 13 DGFIPs des 2 pages"
    end

    within ".header-bar--selection", text: "13 DGFIPs sélectionnées" do
      click_on "Tout supprimer"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer les 13 DGFIPs sélectionnées ?" do
      click_on "Continuer"
    end

    # The browser should stay on index page
    # No DGFIPs should appear anymore
    #
    expect(page).to have_current_path(admin_dgfips_path)
    expect(page).to have_selector("h1", text: "DGFIP")
    expect(page).to have_text("Aucune DGFIP disponible.")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les DGFIPs sélectionnées ont été supprimées.")

    # The notification should include a button to cancel the last action
    #
    within "[role=alert]", text: "Les DGFIPs sélectionnées ont été supprimées." do
      click_on "Annuler"
    end

    # The browser should stay on index page
    # All DGFIPs should be back again
    #
    expect(page).to have_current_path(admin_dgfips_path)
    expect(page).to have_selector("h1", text: "DGFIP")
    expect(page).to have_text("3 DGFIPs | Page 1 sur 2")
    expect(page).to have_selector(:table_row, "DGFIP" => "Ministère de l'Économie et des Finances")
    expect(page).to have_selector(:table_row, "DGFIP" => "Direction nationale d'Enquêtes fiscales")
    expect(page).to have_selector(:table_row, "DGFIP" => "Direction des Vérifications nationales et internationales")

    # The selection message should not appears again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=alert]", text: "Les DGFIPs sélectionnées ont été supprimées.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression des DGFIPs sélectionnées a été annulée.")
  end
end
