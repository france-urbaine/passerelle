# frozen_string_literal: true

require "system_helper"

RSpec.describe "Offices in admin" do
  fixtures :regions, :departements, :epcis, :communes
  fixtures :ddfips, :offices, :users, :office_communes, :office_users, :audits

  let(:ddifp64)      { ddfips(:pyrenees_atlantiques) }
  let(:departement)  { departements(:pyrenees_atlantiques) }
  let(:pelp_bayonne) { offices(:pelp_bayonne) }
  let(:pelh_bayonne) { offices(:pelh_bayonne) }

  before { sign_in(users(:marc)) }

  it "visits index & office pages" do
    visit admin_offices_path

    # A table of all offices should be present
    #
    expect(page).to have_selector("h1", text: "Guichets")
    expect(page).to have_link("PELP de Bayonne")

    click_on "PELP de Bayonne"

    # The browser should visit the office page
    #
    expect(page).to have_current_path(admin_office_path(pelp_bayonne))
    expect(page).to have_selector("h1", text: "PELP de Bayonne")

    go_back

    # The browser should redirect back to the index page
    #
    expect(page).to have_current_path(admin_offices_path)
    expect(page).to have_selector("h1", text: "Guichets")
  end

  it "visits office & audits pages" do
    visit admin_offices_path
    click_on "PELP de Bayonne"

    # The browser should visit the office page
    #
    expect(page).to have_current_path(admin_office_path(pelp_bayonne))
    expect(page).to have_selector("a.button", text: "Voir toute l'activité")

    click_on "Voir toute l'activité"

    # The browser should visit the office audits page
    #
    expect(page).to have_current_path(admin_office_audits_path(pelp_bayonne))
    expect(page).to have_selector("pre.logs")
  end

  it "searches for offices with simple string criterion" do
    visit admin_offices_path(search: "pyrenees")
    expect(page).to have_link("PELP de Bayonne")
    expect(page).to have_link("PELH de Bayonne")
    expect(page).to have_link("SIP de Bayonne")
  end

  it "searches for offices with hash-like string criteria" do
    visit admin_offices_path(search: "name:SIP ddfip_name:pyrenees")
    expect(page).to have_link("SIP de Bayonne")
    expect(page).to have_no_link("PELP de Bayonne")
    expect(page).to have_no_link("PELH de Bayonne")
  end

  it "searches for offices with hash-like string criteria and simple string criterion" do
    visit admin_offices_path(search: "ddfip_name:pyrenees SIP")
    expect(page).to have_link("SIP de Bayonne")
    expect(page).to have_no_link("PELP de Bayonne")
    expect(page).to have_no_link("PELH de Bayonne")
  end

  it "searches for offices with unknown criterion" do
    visit admin_offices_path(search: "unknown:SIP")
    expect(page).to have_text("Aucun guichet ne correspont à votre recherche.")
  end

  it "visits the links on the office page & comes back" do
    visit admin_office_path(pelp_bayonne)

    # On the office page, we expect:
    # - a link to the DDFIP
    # - a link to the departement
    #
    expect(page).to have_selector("h1", text: "PELP de Bayonne")
    expect(page).to have_link("DDFIP des Pyrénées-Atlantiques")
    expect(page).to have_link("Département des Pyrénées-Atlantiques")

    click_on "DDFIP des Pyrénées-Atlantiques"

    # The browser should visit the DDFIP page
    #
    expect(page).to have_current_path(admin_ddfip_path(ddifp64))
    expect(page).to have_selector("h1", text: "DDFIP des Pyrénées-Atlantiques")

    go_back

    # The browser should redirect back to the office page
    #
    expect(page).to have_current_path(admin_office_path(pelp_bayonne))
    expect(page).to have_selector("h1", text: "PELP de Bayonne")

    click_on "Département des Pyrénées-Atlantiques"

    # The browser should visit the DDFIP page
    #
    expect(page).to have_current_path(territories_departement_path(departement))
    expect(page).to have_selector("h1", text: "Pyrénées-Atlantiques")

    go_back

    # The browser should redirect back to the office page
    #
    expect(page).to have_current_path(admin_office_path(pelp_bayonne))
    expect(page).to have_selector("h1", text: "PELP de Bayonne")
  end

  it "creates an office from the index page" do
    visit admin_offices_path

    # A button should be present to add a new office
    #
    click_on "Ajouter un guichet"

    # A dialog box should appear with a form to fill
    #
    within "[role=dialog]", text: "Création d'un nouveau guichet" do |dialog|
      expect(dialog).to have_field("DDFIP",          with: nil)
      expect(dialog).to have_field("Nom du guichet", with: nil)

      within ".form-block", text: "Compétences" do |block|
        expect(block).to have_unchecked_field("Tout sélectionner")
        expect(block).to have_unchecked_field("Évaluation des locaux d'habitation")
        expect(block).to have_unchecked_field("Évaluation des locaux professionnels")
      end

      fill_in "DDFIP", with: "64"
      select_option "DDFIP des Pyrénées-Atlantiques", from: "DDFIP"

      fill_in "Nom du guichet", with: "SIP de Pau"
      check   "Occupation des locaux d'habitation"

      click_on "Enregistrer"
    end

    # The browser should stay on the index page
    # The new office should appear
    #
    expect(page).to have_current_path(admin_offices_path)
    expect(page).to have_selector("h1", text: "Guichets")
    expect(page).to have_selector(:table_row, "Guichet" => "SIP de Pau")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to have_no_selector("[role=dialog]")
    expect(page).to have_selector("[role=log]", text: "Un nouveau guichet a été ajouté avec succés.")
  end

  it "updates an office from the index page" do
    visit admin_offices_path

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

      within ".form-block", text: "Compétences" do |block|
        expect(block).to have_unchecked_field("Évaluation des locaux d'habitation")
        expect(block).to have_checked_field("Évaluation des locaux professionnels")
      end

      fill_in "Nom du guichet", with: "PELP de Bayonne-Anglet-Biarritz"
      click_on "Enregistrer"
    end

    # The browser should stay on the index page
    # The office should have changed its name
    #
    expect(page).to have_current_path(admin_offices_path)
    expect(page).to have_selector("h1", text: "Guichets")
    expect(page).to have_selector(:table_row, "Guichet" => "PELP de Bayonne-Anglet-Biarritz")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to have_no_selector("[role=dialog]")
    expect(page).to have_selector("[role=log]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "updates an office from the office page" do
    visit admin_office_path(pelp_bayonne)

    # A button should be present to edit the office
    #
    within ".breadcrumbs", text: "PELP de Bayonne" do
      click_on "Modifier"
    end

    # A dialog box should appear with a form
    # The form should be filled with office data
    #
    within "[role=dialog]", text: "Modification du guichet" do |dialog|
      expect(dialog).to have_field("DDFIP",          with: "DDFIP des Pyrénées-Atlantiques")
      expect(dialog).to have_field("Nom du guichet", with: "PELP de Bayonne")

      within ".form-block", text: "Compétences" do |block|
        expect(block).to have_unchecked_field("Évaluation des locaux d'habitation")
        expect(block).to have_checked_field("Évaluation des locaux professionnels")
      end

      fill_in "Nom du guichet", with: "PELP de Bayonne-Anglet-Biarritz"
      click_on "Enregistrer"
    end

    # The browser should stay on show page
    # The office should have changed its name
    #
    expect(page).to have_current_path(admin_office_path(pelp_bayonne))
    expect(page).to have_selector("h1", text: "PELP de Bayonne-Anglet-Biarritz")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to have_no_selector("[role=dialog]")
    expect(page).to have_selector("[role=log]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "discards an office from the index page & rollbacks" do
    visit admin_offices_path

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

    # The browser should stay on the index page
    # The office should not appear anymore
    #
    expect(page).to have_current_path(admin_offices_path)
    expect(page).to have_selector("h1", text: "Guichets")
    expect(page).to have_text("2 guichets | Page 1 sur 1")
    expect(page).to have_no_selector(:table_row, "Guichet" => "PELP de Bayonne")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to have_no_selector("[role=dialog]")
    expect(page).to have_selector("[role=log]", text: "Le guichet a été supprimé.")

    # The notification should include a button to cancel the last action
    #
    within "[role=log]", text: "Le guichet a été supprimé." do
      click_on "Annuler"
    end

    # The browser should stay on the index page
    # The office should be back again
    #
    expect(page).to have_current_path(admin_offices_path)
    expect(page).to have_selector("h1", text: "Guichets")
    expect(page).to have_text("3 guichets | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "Guichet" => "PELP de Bayonne")

    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).to have_no_selector("[role=log]", text: "Le guichet a été supprimé.")
    expect(page).to have_selector("[role=log]", text: "La suppression du guichet a été annulée.")
  end

  it "discards an office from the office page & rollbacks" do
    visit admin_office_path(pelp_bayonne)

    # A button should be present to remove the office
    #
    within ".breadcrumbs", text: "PELP de Bayonne" do
      click_on "Supprimer"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer ce guichet ?" do
      click_on "Continuer"
    end

    # The browser should redirect to the index page
    # The office should not appear anymore
    #
    expect(page).to have_current_path(admin_offices_path)
    expect(page).to have_selector("h1", text: "Guichets")
    expect(page).to have_text("2 guichets | Page 1 sur 1")
    expect(page).to have_no_selector(:table_row, "Guichet" => "PELP de Bayonne")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to have_no_selector("[role=dialog]")
    expect(page).to have_selector("[role=log]", text: "Le guichet a été supprimé.")

    # The notification should include a button to cancel the last action
    #
    within "[role=log]", text: "Le guichet a été supprimé." do
      click_on "Annuler"
    end

    # The browser should stay on the index page
    # The office should be back again
    #
    expect(page).to have_current_path(admin_offices_path)
    expect(page).to have_selector("h1", text: "Guichets")
    expect(page).to have_text("3 guichets | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "Guichet" => "PELP de Bayonne")

    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).to have_no_selector("[role=log]", text: "Le guichet a été supprimé.")
    expect(page).to have_selector("[role=log]", text: "La suppression du guichet a été annulée.")
  end

  it "selects and discards one office from the index page & rollbacks" do
    visit admin_offices_path

    expect(page).to have_text("3 guichets | Page 1 sur 1")

    # Checkboxes should be present to select offices
    #
    within :table_row, { "Guichet" => "PELP de Bayonne" } do
      check
    end

    # A message should diplay the number of selected offices
    # with a button to remove them
    #
    within ".datatable__selection", text: "1 guichet sélectionné" do
      click_on "Tout supprimer"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer le guichet sélectionné ?" do
      click_on "Continuer"
    end

    # The browser should stay on index page
    # The selected offices should not appear anymore
    # Other offices should remain
    #
    expect(page).to have_current_path(admin_offices_path)
    expect(page).to have_selector("h1", text: "Guichets")
    expect(page).to have_text("2 guichets | Page 1 sur 1")
    expect(page).to have_no_selector(:table_row, "Guichet" => "PELP de Bayonne")
    expect(page).to have_selector(:table_row, "Guichet" => "PELH de Bayonne")
    expect(page).to have_selector(:table_row, "Guichet" => "SIP de Bayonne")

    # The selection message should not appear anymore
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to have_no_selector(".datatable__selection")
    expect(page).to have_no_selector("[role=dialog]")
    expect(page).to have_selector("[role=log]", text: "Les guichets sélectionnés ont été supprimés.")

    # The notification should include a button to cancel the last action
    #
    within "[role=log]", text: "Les guichets sélectionnés ont été supprimés." do
      click_on "Annuler"
    end

    # The browser should stay on index page
    # The remove offices should be back again
    #
    expect(page).to have_current_path(admin_offices_path)
    expect(page).to have_selector("h1", text: "Guichets")
    expect(page).to have_text("3 guichets | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "Guichet" => "PELP de Bayonne")

    # The selection message should not appear again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).to have_no_selector(".datatable__selection")
    expect(page).to have_no_selector("[role=log]", text: "Les guichets sélectionnés ont été supprimés.")
    expect(page).to have_selector("[role=log]", text: "La suppression des guichets sélectionnés a été annulée.")
  end

  it "selects and discards all offices from the current page on index page & rollbacks" do
    # Create a bunch of offices to have several pages
    # Create discarded offices to verify they are not rollbacked
    #
    create_list(:office, 10, name_pattern: "Guichet #%{sequence}")
    create_list(:office, 5, :discarded, name_pattern: "Guichet #%{sequence}")

    visit admin_offices_path

    expect(page).to have_text("13 guichets | Page 1 sur 1")

    # Paginate offices by 10
    # More than one page should exist
    #
    click_on "Options d'affichage"
    click_on "Afficher 50 lignes par page"
    click_on "Afficher 10 lignes"

    expect(page).to have_text("13 guichets | Page 1 sur 2")

    # Checkboxes should be present to select all offices
    #
    within :table do
      check nil, match: :first
    end

    # A message should diplay the number of selected offices
    # with a button to remove them
    #
    within ".datatable__selection", text: "10 guichets sélectionnés" do
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
    expect(page).to have_current_path(admin_offices_path)
    expect(page).to have_selector("h1", text: "Guichets")
    expect(page).to have_text("3 guichets | Page 1 sur 1")
    expect(page).to have_no_selector(:table_row, "Guichet" => "PELP de Bayonne")
    expect(page).to have_no_selector(:table_row, "Guichet" => "PELH de Bayonne")
    expect(page).to have_no_selector(:table_row, "Guichet" => "SIP de Bayonne")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to have_no_selector(".datatable__selection")
    expect(page).to have_no_selector("[role=dialog]")
    expect(page).to have_selector("[role=log]", text: "Les guichets sélectionnés ont été supprimés.")

    # The notification should include a button to cancel the last action
    #
    within "[role=log]", text: "Les guichets sélectionnés ont été supprimés." do
      click_on "Annuler"
    end

    # The browser should stay on index page
    # All offices should be back again
    #
    expect(page).to have_current_path(admin_offices_path)
    expect(page).to have_selector("h1", text: "Guichets")
    expect(page).to have_text("3 guichets | Page 1 sur 2")
    expect(page).to have_selector(:table_row, "Guichet" => "PELP de Bayonne")
    expect(page).to have_selector(:table_row, "Guichet" => "PELH de Bayonne")
    expect(page).to have_selector(:table_row, "Guichet" => "SIP de Bayonne")

    # The selection message should not appear again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).to have_no_selector(".datatable__selection")
    expect(page).to have_no_selector("[role=log]", text: "Les guichets sélectionnés ont été supprimés.")
    expect(page).to have_selector("[role=log]", text: "La suppression des guichets sélectionnés a été annulée.")
  end

  it "selects and discards all offices through several pages on index page & rollbacks" do
    # Create a bunch of offices to have several pages
    # TODO: Create discarded offices to verify they are not rollbacked
    #
    create_list(:office, 10, name_pattern: "Guichet #%{sequence}")

    visit admin_offices_path

    expect(page).to have_text("13 guichets | Page 1 sur 1")

    # Paginate offices by 10
    # More than one page should exist
    #
    click_on "Options d'affichage"
    click_on "Afficher 50 lignes par page"
    click_on "Afficher 10 lignes"

    expect(page).to have_text("13 guichets | Page 1 sur 2")

    # Checkboxes should be present to select all offices
    #
    within :table do
      check nil, match: :first
    end

    # A message should diplay the number of selected offices
    # A link to select any offices from any page should be present
    # A link to remove all of them should be present
    #
    within ".datatable__selection", text: "10 guichets sélectionnés" do
      click_on "Sélectionner les 13 guichets des 2 pages"
    end

    within ".datatable__selection", text: "13 guichets sélectionnés" do
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
    expect(page).to have_current_path(admin_offices_path)
    expect(page).to have_selector("h1", text: "Guichets")
    expect(page).to have_text("Aucun guichet disponible.")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to have_no_selector(".datatable__selection")
    expect(page).to have_no_selector("[role=dialog]")
    expect(page).to have_selector("[role=log]", text: "Les guichets sélectionnés ont été supprimés.")

    # The notification should include a button to cancel the last action
    #
    within "[role=log]", text: "Les guichets sélectionnés ont été supprimés." do
      click_on "Annuler"
    end

    # The browser should stay on index page
    # All offices should be back again
    #
    expect(page).to have_current_path(admin_offices_path)
    expect(page).to have_selector("h1", text: "Guichets")
    expect(page).to have_text("3 guichets | Page 1 sur 2")
    expect(page).to have_selector(:table_row, "Guichet" => "PELP de Bayonne")
    expect(page).to have_selector(:table_row, "Guichet" => "PELH de Bayonne")
    expect(page).to have_selector(:table_row, "Guichet" => "SIP de Bayonne")

    # The selection message should not appear again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).to have_no_selector(".datatable__selection")
    expect(page).to have_no_selector("[role=log]", text: "Les guichets sélectionnés ont été supprimés.")
    expect(page).to have_selector("[role=log]", text: "La suppression des guichets sélectionnés a été annulée.")
  end
end
