# frozen_string_literal: true

require "system_helper"

RSpec.describe "Publishers" do
  fixtures :publishers, :collectivities, :users

  let(:fiscalite_territoire) { publishers(:fiscalite_territoire) }
  let(:pays_basque)          { collectivities(:pays_basque) }

  it "visits index & show pages" do
    visit publishers_path

    expect(page).to have_selector("h1", text: "Éditeurs")
    expect(page).to have_link("Fiscalité & Territoire")

    click_on "Fiscalité & Territoire"

    expect(page).to have_selector("h1", text: "Fiscalité & Territoire")
    expect(page).to have_current_path(publisher_path(fiscalite_territoire))
  end

  it "visits links from the show page & comes back" do
    visit publisher_path(fiscalite_territoire)

    expect(page).to have_selector("h1", text: "Fiscalité & Territoire")
    expect(page).to have_link("CA du Pays Basque")
    expect(page).to have_link("Bayonne")

    click_on "CA du Pays Basque"

    expect(page).to have_selector("h1", text: "CA du Pays Basque")
    expect(page).to have_current_path(collectivity_path(pays_basque))

    go_back

    expect(page).to have_selector("h1", text: "Fiscalité & Territoire")
    expect(page).to have_current_path(publisher_path(fiscalite_territoire))
  end

  it "creates a publisher from the index page" do
    visit publishers_path

    # A button should be present to add a new publisher
    #
    expect(page).to have_link("Ajouter un éditeur", class: "button")

    click_on "Ajouter un éditeur"

    # A dialog box should appears with a form to fill
    #
    expect(page).to have_selector("[role=dialog]", text: "Création d'un nouvel éditeur")

    within "[role=dialog]" do
      fill_in  "Nom de l'éditeur",          with: "Solutions & Territoire"
      fill_in  "Numéro SIREN de l'éditeur", with: "848905758"

      click_on "Enregistrer"
    end

    # The browser should stay on index page
    # The new publisher should appears
    #
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to     have_current_path(publishers_path)
    expect(page).to     have_selector("h1", text: "Éditeurs")
    expect(page).to     have_selector("tr", text: "Solutions & Territoire")

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Un nouvel éditeur a été ajouté avec succés.")
  end

  it "updates a publisher from the index page" do
    visit publishers_path

    # A button should be present to edit the publisher
    #
    within "tr", text: "Fiscalité & Territoire" do |row|
      expect(row).to have_link("Modifier cet éditeur", class: "icon-button")

      click_on "Modifier cet éditeur"
    end

    # A dialog box should appears with a form
    # The form should be filled with publisher data
    #
    expect(page).to have_selector("[role=dialog]", text: "Modification de l'éditeur")

    within "[role=dialog]" do
      expect(page).to have_field("Nom de l'éditeur",          with: "Fiscalité & Territoire")
      expect(page).to have_field("Numéro SIREN de l'éditeur", with: "511022394")

      fill_in  "Nom de l'éditeur", with: "Solutions & Territoire"

      click_on "Enregistrer"
    end

    # The browser should stay on index page
    # The publisher should have changed its name
    #
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to     have_current_path(publishers_path)
    expect(page).to     have_selector("h1", text: "Éditeurs")
    expect(page).to     have_selector("tr", text: "Solutions & Territoire")

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "updates a publisher from the show page" do
    visit publisher_path(fiscalite_territoire)

    # A button should be present to edit the publisher
    #
    within ".header-bar" do |header|
      expect(header).to have_selector("h1", text: "Fiscalité & Territoire")
      expect(header).to have_link("Modifier", class: "button")

      click_on "Modifier"
    end

    # A dialog box should appears with a form
    # The form should be filled with publisher data
    #
    expect(page).to have_selector("[role=dialog]", text: "Modification de l'éditeur")

    within "[role=dialog]" do
      expect(page).to have_field("Nom de l'éditeur", with: "Fiscalité & Territoire")
      expect(page).to have_field("Numéro SIREN de l'éditeur", with: "511022394")

      fill_in  "Nom de l'éditeur", with: "Solutions & Territoire"
      click_on "Enregistrer"
    end

    # The browser should stay on show page
    # The publisher should have changed its name
    #
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to     have_current_path(publisher_path(fiscalite_territoire))
    expect(page).to     have_selector("h1", text: "Solutions & Territoire")

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "removes a publisher from the index page and then rollback" do
    visit publishers_path

    # A button should be present to remove this publisher
    #
    within "tr", text: "Fiscalité & Territoire" do |row|
      expect(row).to have_link("Supprimer cet éditeur", class: "icon-button")

      click_on "Supprimer cet éditeur"
    end

    # A confirmation dialog should appears
    #
    expect(page).to have_selector("[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer cet éditeur ?")

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
    expect(page).to     have_current_path(publishers_path)
    expect(page).to     have_selector("h1", text: "Éditeurs")
    expect(page).not_to have_selector("tr", text: "Fiscalité & Territoire")

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "L'éditeur a été supprimé.")

    # The notification should include a button to cancel the last action
    #
    within "[role=alert]", text: "L'éditeur a été supprimé." do |alert|
      expect(alert).to have_button("Annuler")

      click_on "Annuler"
    end

    # The browser should stay on index page
    # The publisher should be back again
    #
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).to     have_current_path(publishers_path)
    expect(page).to     have_selector("h1", text: "Éditeurs")
    expect(page).to     have_selector("tr", text: "Fiscalité & Territoire")

    expect(page).not_to have_selector("[role=alert]", text: "L'éditeur a été supprimé.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression de l'éditeur a été annulée.")
  end

  it "removes a publisher from the show page and then rollback" do
    visit publisher_path(fiscalite_territoire)

    # A button should be present to remove this publisher
    #
    within ".header-bar" do |header|
      expect(header).to have_selector("h1", text: "Fiscalité & Territoire")
      expect(header).to have_link("Supprimer", class: "button")

      click_on "Supprimer"
    end

    # A confirmation dialog should appears
    #
    expect(page).to have_selector("[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer cet éditeur ?")

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
    expect(page).to     have_current_path(publishers_path)
    expect(page).to     have_selector("h1", text: "Éditeurs")
    expect(page).not_to have_selector("tr", text: "Fiscalité & Territoire")

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "L'éditeur a été supprimé.")

    # The notification should include a button to cancel the last action
    #
    within "[role=alert]", text: "L'éditeur a été supprimé." do |alert|
      expect(alert).to have_button("Annuler")

      click_on "Annuler"
    end

    # The browser should stay on index page
    # The publisher should be back again
    #
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).to     have_current_path(publishers_path)
    expect(page).to     have_selector("h1", text: "Éditeurs")
    expect(page).to     have_selector("tr", text: "Fiscalité & Territoire")

    expect(page).not_to have_selector("[role=alert]", text: "L'éditeur a été supprimé.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression de l'éditeur a été annulée.")
  end

  it "removes a selection of publishers from the index page and then rollback" do
    visit publishers_path

    # Some checkboxes should be present to select publishers
    #
    within "tr", text: "Fiscalité & Territoire" do
      find("input[type=checkbox]").check
    end

    # A message should diplay the number of selected publishers
    # with a button to remove them
    #
    within "#datatable-publishers-selection-bar" do |header|
      expect(header).to have_text("1 éditeur sélectionné")
      expect(header).to have_link("Supprimer la sélection", class: "button")

      click_on "Supprimer la sélection"
    end

    # A confirmation dialog should appears
    #
    expect(page).to have_selector("[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer l'éditeur sélectionné ?")

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
    expect(page).to     have_current_path(publishers_path)
    expect(page).to     have_selector("h1", text: "Éditeurs")
    expect(page).not_to have_selector("tr", text: "Fiscalité & Territoire")

    expect(page).not_to have_selector("#datatable-publishers-selection-bar", text: "1 éditeur sélectionné")
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les éditeurs sélectionnés ont été supprimés.")

    # The notification should include a button to cancel the last action
    #
    within "[role=alert]", text: "Les éditeurs sélectionnés ont été supprimés." do |alert|
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
    expect(page).to     have_current_path(publishers_path)
    expect(page).to     have_selector("h1", text: "Éditeurs")
    expect(page).to     have_selector("tr", text: "Fiscalité & Territoire")

    expect(page).not_to have_selector("#datatable-publishers-selection-bar", text: "1 éditeur sélectionné")
    expect(page).not_to have_selector("[role=alert]", text: "Les éditeurs sélectionnés ont été supprimés.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression des éditeurs sélectionnés a été annulée.")
  end
end
