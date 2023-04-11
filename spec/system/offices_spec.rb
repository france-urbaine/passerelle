# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Offices", use_fixtures: true do
  fixtures :regions, :departements, :ddfips, :offices

  let(:ddifp64)      { ddfips(:pyrenees_atlantiques) }
  let(:pelp_bayonne) { offices(:pelp_bayonne) }

  it "visits index & show pages" do
    visit offices_path

    expect(page).to have_selector("h1", text: "Guichets")
    expect(page).to have_link("PELP de Bayonne")

    click_on "PELP de Bayonne"

    expect(page).to have_selector("h1", text: "PELP de Bayonne")
    expect(page).to have_current_path(office_path(pelp_bayonne))
  end

  it "visits links from the show page & comes back" do
    visit office_path(pelp_bayonne)

    expect(page).to have_selector("h1", text: "PELP de Bayonne")
    expect(page).to have_link("DDFIP des Pyrénées-Atlantiques")

    click_on "DDFIP des Pyrénées-Atlantiques"

    expect(page).to have_selector("h1", text: "DDFIP des Pyrénées-Atlantiques")
    expect(page).to have_current_path(ddfip_path(ddifp64))

    go_back

    expect(page).to have_selector("h1", text: "PELP de Bayonne")
    expect(page).to have_current_path(office_path(pelp_bayonne))
  end

  it "creates a office from the index page" do
    visit offices_path

    # A button should be present to add a new publisher
    #
    expect(page).to have_link("Ajouter un guichet", class: "button")

    click_on "Ajouter un guichet"

    # A dialog box should appears with a form to fill
    #
    expect(page).to have_selector("[role=dialog]", text: "Création d'un nouveau guichet")

    within "[role=dialog]" do
      fill_in "DDFIP", with: "64"
      find("[role=option]", text: "DDFIP des Pyrénées-Atlantiques").click

      fill_in "Nom du guichet", with: "SIP de Pau"
      select "Occupation de locaux d'habitation", from: "Action"

      click_on "Enregistrer"
    end

    # The browser should stay on index page
    # The new publisher should appears
    #
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to     have_current_path(offices_path)
    expect(page).to     have_selector("h1", text: "Guichets")
    expect(page).to     have_selector("tr", text: "SIP de Pau")

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Un nouveau guichet a été ajouté avec succés.")
  end

  it "updates a office from the index page" do
    visit offices_path

    # A button should be present to edit the publisher
    #
    within "tr", text: "PELP de Bayonne" do |row|
      expect(row).to have_link("Modifier ce guichet", class: "icon-button")

      click_on "Modifier ce guichet"
    end

    # A dialog box should appears with a form
    # The form should be filled with publisher data
    #
    expect(page).to have_selector("[role=dialog]", text: "Modification du guichet")

    within "[role=dialog]" do
      expect(page).to have_field("DDFIP",          with: "DDFIP des Pyrénées-Atlantiques")
      expect(page).to have_field("Nom du guichet", with: "PELP de Bayonne")
      expect(page).to have_select("Action",        selected: "Évaluation de locaux économiques")

      fill_in  "Nom du guichet", with: "PELP de Bayonne-Anglet-Biarritz"
      click_on "Enregistrer"
    end

    # The browser should stay on index page
    # The publisher should have changed its name
    #
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to     have_current_path(offices_path)
    expect(page).to     have_selector("h1", text: "Guichets")
    expect(page).to     have_selector("tr", text: "PELP de Bayonne-Anglet-Biarritz")

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "updates a office from the show page" do
    visit office_path(pelp_bayonne)

    # A button should be present to edit the publisher
    #
    within ".header-bar" do |header|
      expect(header).to have_selector("h1", text: "PELP de Bayonne")
      expect(header).to have_link("Modifier", class: "button")

      click_on "Modifier"
    end

    # A dialog box should appears with a form
    # The form should be filled with publisher data
    #
    expect(page).to have_selector("[role=dialog]", text: "Modification du guichet")

    within "[role=dialog]" do
      expect(page).to have_field("DDFIP",          with: "DDFIP des Pyrénées-Atlantiques")
      expect(page).to have_field("Nom du guichet", with: "PELP de Bayonne")
      expect(page).to have_select("Action",        selected: "Évaluation de locaux économiques")

      fill_in  "Nom du guichet", with: "PELP de Bayonne-Anglet-Biarritz"

      click_on "Enregistrer"
    end

    # The browser should stay on show page
    # The publisher should have changed its name
    #
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to     have_current_path(office_path(pelp_bayonne))
    expect(page).to     have_selector("h1", text: "PELP de Bayonne-Anglet-Biarritz")

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "removes a office from the index page and then rollback" do
    visit offices_path

    # A button should be present to remove this publisher
    #
    within "tr", text: "PELP de Bayonne" do |row|
      expect(row).to have_link("Supprimer ce guichet", class: "icon-button")

      click_on "Supprimer ce guichet"
    end

    # A confirmation dialog should appears
    #
    expect(page).to have_selector("[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer ce guichet ?")

    within "[role=dialog]" do |dialog|
      expect(dialog).to have_button("Continuer")

      click_on "Continuer"
    end

    # The browser should stay on index page
    # The publisher should not appears anymore
    #
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to     have_current_path(offices_path)
    expect(page).to     have_selector("h1", text: "Guichets")
    expect(page).not_to have_selector("tr", text: "PELP de Bayonne")

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Le guichet a été supprimé.")

    # The notification should include a button to cancel the last action
    #
    within "[role=alert]", text: "Le guichet a été supprimé." do |alert|
      expect(alert).to have_button("Annuler")

      click_on "Annuler"
    end

    # The browser should stay on index page
    # The publisher should be back again
    #
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).to     have_current_path(offices_path)
    expect(page).to     have_selector("h1", text: "Guichets")
    expect(page).to     have_selector("tr", text: "PELP de Bayonne")

    expect(page).not_to have_selector("[role=alert]", text: "Le guichet a été supprimé.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression du guichet a été annulée.")
  end

  it "removes a office from the show page and then rollback" do
    visit office_path(pelp_bayonne)

    # A button should be present to remove this publisher
    #
    within ".header-bar" do |header|
      expect(header).to have_selector("h1", text: "PELP de Bayonne")
      expect(header).to have_link("Supprimer", class: "button")

      click_on "Supprimer"
    end

    # A confirmation dialog should appears
    #
    expect(page).to have_selector("[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer ce guichet ?")

    within "[role=dialog]" do |dialog|
      expect(dialog).to have_button("Continuer")

      click_on "Continuer"
    end

    # The browser should stay on index page
    # The publisher should not appears anymore
    #
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to     have_current_path(offices_path)
    expect(page).to     have_selector("h1", text: "Guichets")
    expect(page).not_to have_selector("tr", text: "PELP de Bayonne")

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Le guichet a été supprimé.")

    # The notification should include a button to cancel the last action
    #
    within "[role=alert]", text: "Le guichet a été supprimé." do |alert|
      expect(alert).to have_button("Annuler")

      click_on "Annuler"
    end

    # The browser should stay on index page
    # The publisher should be back again
    #
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).to     have_current_path(offices_path)
    expect(page).to     have_selector("h1", text: "Guichets")
    expect(page).to     have_selector("tr", text: "PELP de Bayonne")

    expect(page).not_to have_selector("[role=alert]", text: "Le guichet a été supprimé.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression du guichet a été annulée.")
  end

  it "removes a selection of offices from the index page and then rollback" do
    visit offices_path

    # Some checkboxes should be present to select publishers
    #
    within "tr", text: "PELP de Bayonne" do
      find("input[type=checkbox]").check
    end

    # A message should diplay the number of selected publishers
    # with a button to remove them
    #
    within "#index_header" do |header|
      expect(header).to have_text("1 guichet sélectionné")
      expect(header).to have_link("Supprimer la sélection", class: "button")

      click_on "Supprimer la sélection"
    end

    # A confirmation dialog should appears
    #
    expect(page).to have_selector("[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer le guichet sélectionné ?")

    within "[role=dialog]" do |dialog|
      expect(dialog).to have_button("Continuer")

      click_on "Continuer"
    end

    # The browser should stay on index page
    # The selected publishers should not appears anymore
    #
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to     have_current_path(offices_path)
    expect(page).to     have_selector("h1", text: "Guichets")
    expect(page).not_to have_selector("tr", text: "PELP de Bayonne")

    expect(page).not_to have_selector("#index_header", text: "1 guichet sélectionné")
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les guichets sélectionnés ont été supprimés.")

    # The notification should include a button to cancel the last action
    #
    within "[role=alert]", text: "Les guichets sélectionnés ont été supprimés." do |alert|
      expect(alert).to have_button("Annuler")

      click_on "Annuler"
    end

    # The browser should stay on index page
    # The remove publishers should be back again
    #
    # The selection message should not appears again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).to     have_current_path(offices_path)
    expect(page).to     have_selector("h1", text: "Guichets")
    expect(page).to     have_selector("tr", text: "PELP de Bayonne")

    expect(page).not_to have_selector("#index_header", text: "1 guichet sélectionné")
    expect(page).not_to have_selector("[role=alert]", text: "Les guichets sélectionnés ont été supprimés.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression des guichets sélectionnés a été annulée.")
  end
end
