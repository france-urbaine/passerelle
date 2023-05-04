# frozen_string_literal: true

require "system_helper"

RSpec.describe "DDFIPs" do
  fixtures :regions, :departements
  fixtures :ddfips, :offices

  let(:ddfip64)              { ddfips(:pyrenees_atlantiques) }
  let(:pyrenees_atlantiques) { departements(:pyrenees_atlantiques) }
  let(:nouvelle_aquitaine)   { regions(:nouvelle_aquitaine) }
  let(:pelp_bayonne)         { offices(:pelp_bayonne) }

  it "visits index & show pages" do
    visit ddfips_path

    expect(page).to have_selector("h1", text: "DDFIP")
    expect(page).to have_link("DDFIP des Pyrénées-Atlantiques")

    click_on "DDFIP des Pyrénées-Atlantiques"

    expect(page).to have_selector("h1", text: "DDFIP des Pyrénées-Atlantiques")
    expect(page).to have_current_path(ddfip_path(ddfip64))
  end

  it "visits links from the show page & comes back" do
    visit ddfip_path(ddfip64)

    expect(page).to have_selector("h1", text: "DDFIP des Pyrénées-Atlantiques")
    expect(page).to have_link("Pyrénées-Atlantiques")
    expect(page).to have_link("PELP de Bayonne")

    click_on "Pyrénées-Atlantiques"

    expect(page).to have_selector("h1", text: "Pyrénées-Atlantiques")
    expect(page).to have_current_path(departement_path(pyrenees_atlantiques))

    go_back

    expect(page).to have_selector("h1", text: "DDFIP des Pyrénées-Atlantiques")
    expect(page).to have_current_path(ddfip_path(ddfip64))

    click_on "PELP de Bayonne"

    expect(page).to have_selector("h1", text: "PELP de Bayonne")
    expect(page).to have_current_path(office_path(pelp_bayonne))

    go_back

    expect(page).to have_selector("h1", text: "DDFIP des Pyrénées-Atlantiques")
    expect(page).to have_current_path(ddfip_path(ddfip64))
  end

  it "creates a DDFIP from the index page" do
    visit ddfips_path

    # A button should be present to add a new DDFIP
    #
    expect(page).to have_link("Ajouter une DDFIP", class: "button")

    click_on "Ajouter une DDFIP"

    # A dialog box should appears with a form to fill
    #
    expect(page).to have_selector("[role=dialog]", text: "Création d'une nouvelle DDFIP")

    within "[role=dialog]" do
      fill_in "Nom de la DDFIP", with: "DDFIP des Bouches-du-Rhône"
      fill_in "Département",     with: "13"

      find("[role=option]", text: "Bouches-du-Rhône").click

      click_on "Enregistrer"
    end

    # The browser should stay on index page
    # The new DDFIP should appears
    #
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to     have_current_path(ddfips_path)
    expect(page).to     have_selector("h1", text: "DDFIP")
    expect(page).to     have_selector("tr", text: "DDFIP des Bouches-du-Rhône")

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Une nouvelle DDFIP a été ajoutée avec succés.")
  end

  it "updates a DDFIP from the index page" do
    visit ddfips_path

    # A button should be present to edit the DDFIP
    #
    within "tr", text: "DDFIP des Pyrénées-Atlantiques" do |row|
      expect(row).to have_link("Modifier cette DDFIP", class: "icon-button")

      click_on "Modifier cette DDFIP"
    end

    # A dialog box should appears with a form
    # The form should be filled with DDFIP data
    #
    expect(page).to have_selector("[role=dialog]", text: "Modification de la DDFIP")

    within "[role=dialog]" do
      expect(page).to have_field("Nom de la DDFIP", with: "DDFIP des Pyrénées-Atlantiques")
      expect(page).to have_field("Département",     with: "Pyrénées-Atlantiques")

      fill_in  "Nom de la DDFIP", with: "DDFIP du 64"
      click_on "Enregistrer"
    end

    # The browser should stay on index page
    # The DDFIP should have changed its name
    #
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to     have_current_path(ddfips_path)
    expect(page).to     have_selector("h1", text: "DDFIP")
    expect(page).to     have_selector("tr", text: "DDFIP du 64")

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "updates a DDFIP from the show page" do
    visit ddfip_path(ddfip64)

    # A button should be present to edit the DDFIP
    #
    within ".header-bar" do |header|
      expect(header).to have_selector("h1", text: "DDFIP des Pyrénées-Atlantiques")
      expect(header).to have_link("Modifier", class: "button")

      click_on "Modifier"
    end

    # A dialog box should appears with a form
    # The form should be filled with DDFIP data
    #
    expect(page).to have_selector("[role=dialog]", text: "Modification de la DDFIP")

    within "[role=dialog]" do
      expect(page).to have_field("Nom de la DDFIP", with: "DDFIP des Pyrénées-Atlantiques")
      expect(page).to have_field("Département",     with: "Pyrénées-Atlantiques")

      fill_in  "Nom de la DDFIP", with: "DDFIP du 64"
      click_on "Enregistrer"
    end

    # The browser should stay on show page
    # The DDFIP should have changed its name
    #
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to     have_current_path(ddfip_path(ddfip64))
    expect(page).to     have_selector("h1", text: "DDFIP du 64")

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "removes a DDFIP from the index page and then rollback" do
    visit ddfips_path

    # A button should be present to remove this DDFIP
    #
    within "tr", text: "DDFIP des Pyrénées-Atlantiques" do |row|
      expect(row).to have_link("Supprimer cette DDFIP", class: "icon-button")

      click_on "Supprimer cette DDFIP"
    end

    # A confirmation dialog should appears
    #
    expect(page).to have_selector("[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer cette DDFIP ?")

    within "[role=dialog]" do |dialog|
      expect(dialog).to have_button("Continuer")

      click_on "Continuer"
    end

    # The browser should stay on index page
    # The DDFIP should not appears anymore
    #
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to     have_current_path(ddfips_path)
    expect(page).to     have_selector("h1", text: "DDFIP")
    expect(page).not_to have_selector("tr", text: "DDFIP des Pyrénées-Atlantiques")

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "La DDFIP a été supprimée.")

    # The notification should include a button to cancel the last action
    #
    within "[role=alert]", text: "La DDFIP a été supprimée." do |alert|
      expect(alert).to have_button("Annuler")

      click_on "Annuler"
    end

    # The browser should stay on index page
    # The DDFIP should be back again
    #
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).to     have_current_path(ddfips_path)
    expect(page).to     have_selector("h1", text: "DDFIP")
    expect(page).to     have_selector("tr", text: "DDFIP des Pyrénées-Atlantiques")

    expect(page).not_to have_selector("[role=alert]", text: "La DDFIP a été supprimée.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression de la DDFIP a été annulée.")
  end

  it "removes a DDFIP from the show page and then rollback" do
    visit ddfip_path(ddfip64)

    # A button should be present to remove this DDFIP
    #
    within ".header-bar" do |header|
      expect(header).to have_selector("h1", text: "DDFIP des Pyrénées-Atlantiques")
      expect(header).to have_link("Supprimer", class: "button")

      click_on "Supprimer"
    end

    # A confirmation dialog should appears
    #
    expect(page).to have_selector("[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer cette DDFIP ?")

    within "[role=dialog]" do |dialog|
      expect(dialog).to have_button("Continuer")

      click_on "Continuer"
    end

    # The browser should redirect to the index page
    # The DDFIP should not appears anymore
    #
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to     have_current_path(ddfips_path)
    expect(page).to     have_selector("h1", text: "DDFIP")
    expect(page).not_to have_selector("tr", text: "DDFIP des Pyrénées-Atlantiques")

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "La DDFIP a été supprimée.")

    # The notification should include a button to cancel the last action
    #
    within "[role=alert]", text: "La DDFIP a été supprimée." do |alert|
      expect(alert).to have_button("Annuler")

      click_on "Annuler"
    end

    # The browser should stay on index page
    # The DDFIP should be back again
    #
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).to     have_current_path(ddfips_path)
    expect(page).to     have_selector("h1", text: "DDFIP")
    expect(page).to     have_selector("tr", text: "DDFIP des Pyrénées-Atlantiques")

    expect(page).not_to have_selector("[role=alert]", text: "La DDFIP a été supprimée.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression de la DDFIP a été annulée.")
  end

  it "removes a selection of DDFIP from the index page and then rollback" do
    visit ddfips_path

    # Some checkboxes should be present to select DDFIP
    #
    within "tr", text: "DDFIP du Nord" do
      find("input[type=checkbox]").check
    end

    within "tr", text: "DDFIP des Pyrénées-Atlantiques" do
      find("input[type=checkbox]").check
    end

    # A message should diplay the number of selected DDFIP
    # with a button to remove them
    #
    within "#datatable-ddfips-selection-bar" do |header|
      expect(header).to have_text("2 DDFIPs sélectionnées")
      expect(header).to have_link("Supprimer la sélection", class: "button")

      click_on "Supprimer la sélection"
    end

    # A confirmation dialog should appears
    #
    expect(page).to have_selector("[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer les 2 DDFIPs sélectionnées ?")

    within "[role=dialog]" do |dialog|
      expect(dialog).to have_button("Continuer")

      click_on "Continuer"
    end

    # The browser should stay on index page
    # The selected DDFIP should not appears anymore
    #
    # The selection message should have been closed
    # The dialog should be closed too
    # A notification should be displayed
    #
    expect(page).to     have_current_path(ddfips_path)
    expect(page).to     have_selector("h1", text: "DDFIP")
    expect(page).not_to have_selector("tr", text: "DDFIP du Nord")
    expect(page).not_to have_selector("tr", text: "DDFIP des Pyrénées-Atlantiques")

    expect(page).not_to have_selector("#datatable-ddfips-selection-bar", text: "2 DDFIPs sélectionnées")
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les DDFIPs sélectionnées ont été supprimées.")

    # The notification should include a button to cancel the last action
    #
    within "[role=alert]", text: "Les DDFIPs sélectionnées ont été supprimées." do |alert|
      expect(alert).to have_button("Annuler")

      click_on "Annuler"
    end

    # The browser should stay on index page
    # The remove DDFIP should be back again
    #
    # The selection message should not appears again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).to     have_current_path(ddfips_path)
    expect(page).to     have_selector("h1", text: "DDFIP")
    expect(page).to     have_selector("tr", text: "DDFIP du Nord")
    expect(page).to     have_selector("tr", text: "DDFIP des Pyrénées-Atlantiques")

    expect(page).not_to have_selector("#datatable-ddfips-selection-bar", text: "2 DDFIPs sélectionnées")
    expect(page).not_to have_selector("[role=alert]", text: "Les DDFIPs sélectionnées ont été supprimées.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression des DDFIPs sélectionnées a été annulée.")
  end
end
