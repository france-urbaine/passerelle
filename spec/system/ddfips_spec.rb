# frozen_string_literal: true

require "system_helper"

RSpec.describe "DDFIPs" do
  fixtures :regions, :departements
  fixtures :ddfips, :offices, :users

  let(:ddfip64)              { ddfips(:pyrenees_atlantiques) }
  let(:pyrenees_atlantiques) { departements(:pyrenees_atlantiques) }
  let(:nouvelle_aquitaine)   { regions(:nouvelle_aquitaine) }
  let(:pelp_bayonne)         { offices(:pelp_bayonne) }

  before { sign_in(users(:marc)) }

  it "visits index & DDFIP pages" do
    visit ddfips_path

    # A table of all DDFIPs should be present
    #
    expect(page).to have_selector("h1", text: "DDFIP")
    expect(page).to have_link("DDFIP du Nord")
    expect(page).to have_link("DDFIP des Pyrénées-Atlantiques")
    expect(page).to have_link("DDFIP de Paris")

    click_on "DDFIP des Pyrénées-Atlantiques"

    # The browser should visit the DDFIP page
    #
    expect(page).to have_current_path(ddfip_path(ddfip64))
    expect(page).to have_selector("h1", text: "DDFIP des Pyrénées-Atlantiques")

    go_back

    # The browser should redirect back to the index page
    #
    expect(page).to have_current_path(ddfips_path)
    expect(page).to have_selector("h1", text: "DDFIP")
  end

  it "visits links on a DDFIP page & comes back" do
    visit ddfip_path(ddfip64)

    # On the DDFIP page, we expect:
    # - a link to the departement
    # - a link to each offices
    #
    expect(page).to have_selector("h1", text: "DDFIP des Pyrénées-Atlantiques")
    expect(page).to have_link("Département des Pyrénées-Atlantiques")
    expect(page).to have_link("PELP de Bayonne")
    expect(page).to have_link("PELH de Bayonne")
    expect(page).to have_link("SIP de Bayonne")

    click_on "Département des Pyrénées-Atlantiques"

    # The browser should visit the departement page
    #
    expect(page).to have_current_path(departement_path(pyrenees_atlantiques))
    expect(page).to have_selector("h1", text: "Pyrénées-Atlantiques")

    go_back

    # The browser should redirect back to the DDFIP page
    #
    expect(page).to have_current_path(ddfip_path(ddfip64))
    expect(page).to have_selector("h1", text: "DDFIP des Pyrénées-Atlantiques")

    click_on "PELP de Bayonne"

    # The browser should visit the office page
    #
    expect(page).to have_current_path(office_path(pelp_bayonne))
    expect(page).to have_selector("h1", text: "PELP de Bayonne")

    go_back

    # The browser should redirect back to the DDFIP page
    #
    expect(page).to have_current_path(ddfip_path(ddfip64))
    expect(page).to have_selector("h1", text: "DDFIP des Pyrénées-Atlantiques")
  end

  it "creates a DDFIP from the index page" do
    visit ddfips_path

    # A button should be present to add a new DDFIP
    #
    click_on "Ajouter une DDFIP"

    # A dialog box should appear with a form to fill
    #
    within "[role=dialog]", text: "Création d'une nouvelle DDFIP" do |dialog|
      expect(dialog).to have_field("Nom de la DDFIP")
      expect(dialog).to have_field("Département")

      fill_in "Nom de la DDFIP", with: "DDFIP des Bouches-du-Rhône"
      fill_in "Département",     with: "13"
      select_option "Bouches-du-Rhône", from: "Département"

      click_on "Enregistrer"
    end

    # The browser should stay on the index page
    # The new DDFIP should appear
    #
    expect(page).to have_current_path(ddfips_path)
    expect(page).to have_selector("h1", text: "DDFIP")
    expect(page).to have_selector(:table_row, "DDFIP" => "DDFIP des Bouches-du-Rhône")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Une nouvelle DDFIP a été ajoutée avec succés.")
  end

  it "updates a DDFIP from the index page" do
    visit ddfips_path

    # A button should be present to edit the DDFIP
    #
    within :table_row, { "DDFIP" => "DDFIP des Pyrénées-Atlantiques" } do
      click_on "Modifier cette DDFIP"
    end

    # A dialog box should appear with a form
    # The form should be filled with DDFIP data
    #
    within "[role=dialog]", text: "Modification de la DDFIP" do |dialog|
      expect(dialog).to have_field("Nom de la DDFIP", with: "DDFIP des Pyrénées-Atlantiques")
      expect(dialog).to have_field("Département",     with: "Pyrénées-Atlantiques")

      fill_in "Nom de la DDFIP", with: "DDFIP du 64"
      click_on "Enregistrer"
    end

    # The browser should stay on the index page
    # The DDFIP should have changed its name
    #
    expect(page).to have_current_path(ddfips_path)
    expect(page).to have_selector("h1", text: "DDFIP")
    expect(page).to have_selector(:table_row, "DDFIP" => "DDFIP du 64")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "updates a DDFIP from the DDFIP page" do
    visit ddfip_path(ddfip64)

    # A button should be present to edit the DDFIP
    #
    within ".header-bar", text: "DDFIP des Pyrénées-Atlantiques" do
      click_on "Modifier"
    end

    # A dialog box should appear with a form
    # The form should be filled with DDFIP data
    #
    within "[role=dialog]", text: "Modification de la DDFIP" do
      expect(page).to have_field("Nom de la DDFIP", with: "DDFIP des Pyrénées-Atlantiques")
      expect(page).to have_field("Département",     with: "Pyrénées-Atlantiques")

      fill_in "Nom de la DDFIP", with: "DDFIP du 64"
      click_on "Enregistrer"
    end

    # The browser should stay on the DDFIP page
    # The DDFIP should have changed its name
    #
    expect(page).to have_current_path(ddfip_path(ddfip64))
    expect(page).to have_selector("h1", text: "DDFIP du 64")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "discards a DDFIP from the index page & rollbacks" do
    visit ddfips_path

    expect(page).to have_text("3 DDFIPs | Page 1 sur 1")

    # A button should be present to remove the DDFIP
    #
    within :table_row, { "DDFIP" => "DDFIP des Pyrénées-Atlantiques" } do
      click_on "Supprimer cette DDFIP"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer cette DDFIP ?" do
      click_on "Continuer"
    end

    # The browser should stay on the index page
    # The DDFIP should not appears anymore
    #
    expect(page).to     have_current_path(ddfips_path)
    expect(page).to     have_selector("h1", text: "DDFIP")
    expect(page).to     have_text("2 DDFIPs | Page 1 sur 1")
    expect(page).not_to have_selector(:table_row, "DDFIP" => "DDFIP des Pyrénées-Atlantiques")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "La DDFIP a été supprimée.")

    # The notification should include a button to cancel the last action
    #
    within "[role=alert]", text: "La DDFIP a été supprimée." do
      click_on "Annuler"
    end

    # The browser should stay on the index page
    # The DDFIP should be back again
    #
    expect(page).to have_current_path(ddfips_path)
    expect(page).to have_selector("h1", text: "DDFIP")
    expect(page).to have_text("3 DDFIPs | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "DDFIP" => "DDFIP des Pyrénées-Atlantiques")

    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector("[role=alert]", text: "La DDFIP a été supprimée.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression de la DDFIP a été annulée.")
  end

  it "discards a DDFIP from the DDFIP page & rollbacks" do
    visit ddfip_path(ddfip64)

    # A button should be present to remove the DDFIP
    #
    within ".header-bar", text: "DDFIP des Pyrénées-Atlantiques" do
      click_on "Supprimer"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer cette DDFIP ?" do
      click_on "Continuer"
    end

    # The browser should redirect to the index page
    # The DDFIP should not appears anymore
    #
    expect(page).to     have_current_path(ddfips_path)
    expect(page).to     have_selector("h1", text: "DDFIP")
    expect(page).to     have_text("2 DDFIPs | Page 1 sur 1")
    expect(page).not_to have_selector(:table_row, "DDFIP" => "DDFIP des Pyrénées-Atlantiques")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "La DDFIP a été supprimée.")

    # The notification should include a button to cancel the last action
    #
    within "[role=alert]", text: "La DDFIP a été supprimée." do
      click_on "Annuler"
    end

    # The browser should stay on the index page
    # The DDFIP should be back again
    #
    expect(page).to have_current_path(ddfips_path)
    expect(page).to have_selector("h1", text: "DDFIP")
    expect(page).to have_text("3 DDFIPs | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "DDFIP" => "DDFIP des Pyrénées-Atlantiques")

    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector("[role=alert]", text: "La DDFIP a été supprimée.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression de la DDFIP a été annulée.")
  end

  it "selects and discards one DDFIP from the index page & rollbacks" do
    visit ddfips_path

    expect(page).to have_text("3 DDFIPs | Page 1 sur 1")

    # Checkboxes should be present to select DDFIPs
    #
    within :table_row, { "DDFIP" => "DDFIP des Pyrénées-Atlantiques" } do
      check
    end

    # A message should diplay the number of selected DDFIPs
    # with a button to remove them
    #
    within ".header-bar--selection", text: "1 DDFIP sélectionnée" do
      click_on "Tout supprimer"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer la DDFIP sélectionnée ?" do
      click_on "Continuer"
    end

    # The browser should stay on index page
    # The selected DDFIPs should not appears anymore
    # Other DDFIPs should remain
    #
    expect(page).to     have_current_path(ddfips_path)
    expect(page).to     have_selector("h1", text: "DDFIP")
    expect(page).to     have_text("2 DDFIPs | Page 1 sur 1")
    expect(page).not_to have_selector(:table_row, "DDFIP" => "DDFIP des Pyrénées-Atlantiques")
    expect(page).to     have_selector(:table_row, "DDFIP" => "DDFIP du Nord")
    expect(page).to     have_selector(:table_row, "DDFIP" => "DDFIP de Paris")

    # The selection message should not appears anymore
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les DDFIPs sélectionnées ont été supprimées.")

    # The notification should include a button to cancel the last action
    #
    within "[role=alert]", text: "Les DDFIPs sélectionnées ont été supprimées." do
      click_on "Annuler"
    end

    # The browser should stay on index page
    # The remove DDFIPs should be back again
    #
    expect(page).to have_current_path(ddfips_path)
    expect(page).to have_selector("h1", text: "DDFIP")
    expect(page).to have_text("3 DDFIPs | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "DDFIP" => "DDFIP des Pyrénées-Atlantiques")

    # The selection message should not appears again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=alert]", text: "Les DDFIPs sélectionnées ont été supprimées.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression des DDFIPs sélectionnées a été annulée.")
  end

  it "selects and discards all DDFIPs from the current page on index page & rollbacks" do
    # Create a bunch of DDFIPs to have several pages
    # Create discarded DDFIPs to verify they are not rollbacked
    #
    create_list(:ddfip, 10, name_pattern: "DDFIP #%{sequence}")
    create_list(:ddfip, 5, :discarded, name_pattern: "DDFIP #%{sequence}")

    visit ddfips_path

    expect(page).to have_text("3 DDFIPs | Page 1 sur 1")

    # Paginate DDFIPs by 10
    # More than one page should exist
    #
    click_on "Options d'affichage"
    click_on "Afficher 50 lignes par page"
    click_on "Afficher 10 lignes"

    expect(page).to have_text("3 DDFIPs | Page 1 sur 2")

    # Checkboxes should be present to select all DDFIPs
    #
    within :table do
      check nil, match: :first
    end

    # A message should diplay the number of selected DDFIPs
    # with a button to remove them
    #
    within ".header-bar--selection", text: "10 DDFIPs sélectionnées" do
      click_on "Tout supprimer"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer les 10 DDFIPs sélectionnées ?" do
      click_on "Continuer"
    end

    # The browser should stay on index page
    # The selected DDFIPs should have been removed
    #
    expect(page).to     have_current_path(ddfips_path)
    expect(page).to     have_selector("h1", text: "DDFIP")
    expect(page).to     have_text("3 DDFIPs | Page 1 sur 1")
    expect(page).not_to have_selector(:table_row, "DDFIP" => "DDFIP des Pyrénées-Atlantiques")
    expect(page).not_to have_selector(:table_row, "DDFIP" => "DDFIP du Nord")
    expect(page).not_to have_selector(:table_row, "DDFIP" => "DDFIP de Paris")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les DDFIPs sélectionnées ont été supprimées.")

    # The notification should include a button to cancel the last action
    #
    within "[role=alert]", text: "Les DDFIPs sélectionnées ont été supprimées." do
      click_on "Annuler"
    end

    # The browser should stay on index page
    # All DDFIPs should be back again
    #
    expect(page).to have_current_path(ddfips_path)
    expect(page).to have_selector("h1", text: "DDFIP")
    expect(page).to have_text("3 DDFIPs | Page 1 sur 2")
    expect(page).to have_selector(:table_row, "DDFIP" => "DDFIP des Pyrénées-Atlantiques")
    expect(page).to have_selector(:table_row, "DDFIP" => "DDFIP du Nord")
    expect(page).to have_selector(:table_row, "DDFIP" => "DDFIP de Paris")

    # The selection message should not appears again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=alert]", text: "Les DDFIPs sélectionnées ont été supprimées.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression des DDFIPs sélectionnées a été annulée.")
  end

  it "selects and discards all DDFIPs through several pages on index page & rollbacks" do
    # Create a bunch of DDFIPs to have several pages
    # TODO: Create discarded DDFIPs to verify they are not rollbacked
    #
    create_list(:ddfip, 10, name_pattern: "DDFIP #%{sequence}")

    visit ddfips_path

    expect(page).to have_text("13 DDFIPs | Page 1 sur 1")

    # Paginate DDFIPs by 10
    # More than one page should exist
    #
    click_on "Options d'affichage"
    click_on "Afficher 50 lignes par page"
    click_on "Afficher 10 lignes"

    expect(page).to have_text("13 DDFIPs | Page 1 sur 2")

    # Checkboxes should be present to select all DDFIPs
    #
    within :table do
      check nil, match: :first
    end

    # A message should diplay the number of selected DDFIPs
    # A link to select any DDFIPs from any page should be present
    # A link to remove all of them should be present
    #
    within ".header-bar--selection", text: "10 DDFIPs sélectionnées" do
      click_on "Sélectionner les 13 DDFIPs des 2 pages"
    end

    within ".header-bar--selection", text: "13 DDFIPs sélectionnées" do
      click_on "Tout supprimer"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer les 13 DDFIPs sélectionnées ?" do
      click_on "Continuer"
    end

    # The browser should stay on index page
    # No DDFIPs should appear anymore
    #
    expect(page).to have_current_path(ddfips_path)
    expect(page).to have_selector("h1", text: "DDFIP")
    expect(page).to have_text("Aucune DDFIP disponible.")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les DDFIPs sélectionnées ont été supprimées.")

    # The notification should include a button to cancel the last action
    #
    within "[role=alert]", text: "Les DDFIPs sélectionnées ont été supprimées." do
      click_on "Annuler"
    end

    # The browser should stay on index page
    # All DDFIPs should be back again
    #
    expect(page).to have_current_path(ddfips_path)
    expect(page).to have_selector("h1", text: "DDFIP")
    expect(page).to have_text("3 DDFIPs | Page 1 sur 2")
    expect(page).to have_selector(:table_row, "DDFIP" => "DDFIP des Pyrénées-Atlantiques")
    expect(page).to have_selector(:table_row, "DDFIP" => "DDFIP du Nord")
    expect(page).to have_selector(:table_row, "DDFIP" => "DDFIP de Paris")

    # The selection message should not appears again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=alert]", text: "Les DDFIPs sélectionnées ont été supprimées.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression des DDFIPs sélectionnées a été annulée.")
  end
end
