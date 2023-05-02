# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Collectivities", use_fixtures: true do
  fixtures :regions, :departements, :epcis
  fixtures :collectivities, :publishers, :ddfips

  let(:pays_basque) { collectivities(:pays_basque) }
  let(:publisher)   { publishers(:fiscalite_territoire) }
  let(:territoire)  { epcis(:pays_basque) }
  let(:ddfip)       { ddfips(:pyrenees_atlantiques) }

  it "visits index & show pages" do
    visit collectivities_path

    expect(page).to have_selector("h1", text: "Collectivités")
    expect(page).to have_link("CA du Pays Basque")
    expect(page).to have_link("Métropole Européenne de Lille")

    click_on "CA du Pays Basque"

    expect(page).to have_current_path(collectivity_path(pays_basque))
    expect(page).to have_selector("h1", text: "CA du Pays Basque")
  end

  it "visits links from the show page & comes back" do
    visit collectivity_path(pays_basque)

    expect(page).to have_selector("h1", text: "CA du Pays Basque")
    expect(page).to have_link("Fiscalité & Territoire")
    expect(page).to have_link("CA du Pays Basque")

    click_on "Fiscalité & Territoire"

    expect(page).to have_current_path(publisher_path(publisher))
    expect(page).to have_selector("h1", text: "Fiscalité & Territoire")

    go_back

    expect(page).to have_current_path(collectivity_path(pays_basque))
    expect(page).to have_selector("h1", text: "CA du Pays Basque")

    click_on "CA du Pays Basque"

    expect(page).to have_current_path(epci_path(territoire))
    expect(page).to have_selector("h1", text: "CA du Pays Basque")

    go_back

    expect(page).to have_current_path(collectivity_path(pays_basque))
    expect(page).to have_selector("h1", text: "CA du Pays Basque")
  end

  it "creates a collectivity from the index page" do
    visit collectivities_path

    # A button should be present to add a new collectivity
    #
    expect(page).to have_link("Ajouter une collectivité", class: "button")

    click_on "Ajouter une collectivité"

    # A dialog box should appears with a form to fill
    #
    expect(page).to have_selector("[role=dialog]", text: "Création d'une nouvelle collectivité")

    within "[role=dialog]" do |dialog|
      fill_in "Territoire", with: "Aix-Marseille"

      find("[role=option]", text: "Métropole d'Aix-Marseille-Provence").click

      expect(dialog).to have_field("Territoire",                  with: "Métropole d'Aix-Marseille-Provence")
      expect(dialog).to have_field("collectivity_territory_data", type: :hidden, with: {
        type: "EPCI",
        id:   epcis(:metropole_aix_marseille).id
      }.to_json)

      select "Fiscalité & Territoire", from: "Éditeur"

      fill_in "Nom de la collectivité",          with: "Métropole d'Aix-Marseille-Provence"
      fill_in "Numéro SIREN de la collectivité", with: "200054807"

      click_on "Enregistrer"
    end

    # The browser should stay on index page
    # The new collectivity should appears
    #
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to     have_current_path(collectivities_path)
    expect(page).to     have_selector("h1", text: "Collectivités")
    expect(page).to     have_selector("tr", text: "Métropole d'Aix-Marseille-Provence")

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Une nouvelle collectivité a été ajoutée avec succés.")
  end

  it "updates a collectivity from the index page" do
    visit collectivities_path

    # A button should be present to edit the collectivity
    #
    within "tr", text: "CA du Pays Basque" do |row|
      expect(row).to have_link("Modifier cette collectivité", class: "icon-button")

      click_on "Modifier cette collectivité"
    end

    # A dialog box should appears with a form
    # The form should be filled with collectivity data
    #
    expect(page).to have_selector("[role=dialog]", text: "Modification de la collectivité")

    within "[role=dialog]" do |dialog|
      expect(dialog).to have_field("Territoire",                  with: "CA du Pays Basque")
      expect(dialog).to have_field("collectivity_territory_data", type: :hidden, with: { type: "EPCI", id: epcis(:pays_basque).id }.to_json)

      expect(dialog).to have_select("Éditeur", selected: "Fiscalité & Territoire")
      expect(dialog).to have_field("Nom de la collectivité",          with: "CA du Pays Basque")
      expect(dialog).to have_field("Numéro SIREN de la collectivité", with: "200067106")

      fill_in  "Nom de la collectivité", with: "Agglomération du Pays Basque"
      click_on "Enregistrer"
    end

    # The browser should stay on index page
    # The collectivity should have changed its name
    #
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to     have_current_path(collectivities_path)
    expect(page).to     have_selector("h1", text: "Collectivités")
    expect(page).to     have_selector("tr", text: "Agglomération du Pays Basque")

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "updates a collectivity from the show page" do
    visit collectivity_path(pays_basque)

    # A button should be present to edit the collectivity
    #
    within ".header-bar" do |header|
      expect(header).to have_selector("h1", text: "CA du Pays Basque")
      expect(header).to have_link("Modifier", class: "button")

      click_on "Modifier"
    end

    # A dialog box should appears with a form
    # The form should be filled with collectivity data
    #
    expect(page).to have_selector("[role=dialog]", text: "Modification de la collectivité")

    within "[role=dialog]" do |dialog|
      expect(dialog).to have_field("Territoire",                  with: "CA du Pays Basque")
      expect(dialog).to have_field("collectivity_territory_data", type: :hidden, with: { type: "EPCI", id: epcis(:pays_basque).id }.to_json)

      expect(dialog).to have_select("Éditeur", selected: "Fiscalité & Territoire")
      expect(dialog).to have_field("Nom de la collectivité",          with: "CA du Pays Basque")
      expect(dialog).to have_field("Numéro SIREN de la collectivité", with: "200067106")

      fill_in  "Nom de la collectivité", with: "Agglomération du Pays Basque"
      click_on "Enregistrer"
    end

    # The browser should stay on show page
    # The collectivity should have changed its name
    #
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to     have_current_path(collectivity_path(pays_basque))
    expect(page).to     have_selector("h1", text: "Agglomération du Pays Basque")

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "removes a collectivity from the index page and then rollback" do
    visit collectivities_path

    # A button should be present to remove this collectivity
    #
    within "tr", text: "CA du Pays Basque" do |row|
      expect(row).to have_link("Supprimer cette collectivité", class: "icon-button")

      click_on "Supprimer cette collectivité"
    end

    # A confirmation dialog should appears
    #
    expect(page).to have_selector("[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer cette collectivité ?")

    within "[role=dialog]" do |dialog|
      expect(dialog).to have_button("Continuer")

      click_on "Continuer"
    end

    # The browser should stay on index page
    # The collectivity should not appears anymore
    #
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to     have_current_path(collectivities_path)
    expect(page).to     have_selector("h1", text: "Collectivités")
    expect(page).not_to have_selector("tr", text: "CA du Pays Basque")

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "La collectivité a été supprimée.")

    # The notification should include a button to cancel the last action
    #
    within "[role=alert]", text: "La collectivité a été supprimée." do |alert|
      expect(alert).to have_button("Annuler")

      click_on "Annuler"
    end

    # The browser should stay on index page
    # The collectivity should be back again
    #
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).to     have_current_path(collectivities_path)
    expect(page).to     have_selector("h1", text: "Collectivités")
    expect(page).to     have_selector("tr", text: "CA du Pays Basque")

    expect(page).not_to have_selector("[role=alert]", text: "La collectivité a été supprimée.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression de la collectivité a été annulée.")
  end

  it "removes a collectivity from the show page and then rollback" do
    visit collectivity_path(pays_basque)

    # A button should be present to remove this collectivity
    #
    within ".header-bar" do |header|
      expect(header).to have_selector("h1", text: "CA du Pays Basque")
      expect(header).to have_link("Supprimer", class: "button")

      click_on "Supprimer"
    end

    # A confirmation dialog should appears
    #
    expect(page).to have_selector("[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer cette collectivité ?")

    within "[role=dialog]" do |dialog|
      expect(dialog).to have_button("Continuer")

      click_on "Continuer"
    end

    # The browser should redirect to the index page
    # The collectivity should not appears anymore
    #
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to     have_current_path(collectivities_path)
    expect(page).to     have_selector("h1", text: "Collectivités")
    expect(page).not_to have_selector("tr", text: "CA du Pays Basque")

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "La collectivité a été supprimée.")

    # The notification should include a button to cancel the last action
    #
    within "[role=alert]", text: "La collectivité a été supprimée." do |alert|
      expect(alert).to have_button("Annuler")

      click_on "Annuler"
    end

    # The browser should stay on index page
    # The collectivity should be back again
    #
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).to     have_current_path(collectivities_path)
    expect(page).to     have_selector("h1", text: "Collectivités")
    expect(page).to     have_selector("tr", text: "CA du Pays Basque")

    expect(page).not_to have_selector("[role=alert]", text: "La collectivité a été supprimée.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression de la collectivité a été annulée.")
  end

  it "removes a selection of collectivities from the index page and then rollback" do
    visit collectivities_path

    # Some checkboxes should be present to select collectivities
    #
    within "tr", text: "CA du Pays Basque" do
      find("input[type=checkbox]").check
    end

    within "tr", text: "Métropole Européenne de Lille" do
      find("input[type=checkbox]").check
    end

    # A message should diplay the number of selected collectivities
    # with a button to remove them
    #
    within "#datatable-collectivities-selection-bar" do |header|
      expect(header).to have_text("2 collectivités sélectionnées")
      expect(header).to have_link("Supprimer la sélection", class: "button")

      click_on "Supprimer la sélection"
    end

    # A confirmation dialog should appears
    #
    expect(page).to have_selector("[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer les 2 collectivités sélectionnées ?")

    within "[role=dialog]" do |dialog|
      expect(dialog).to have_button("Continuer")

      click_on "Continuer"
    end

    # The browser should stay on index page
    # The selected collectivities should not appears anymore
    #
    # The selection message should have been closed
    # The dialog should be closed too
    # A notification should be displayed
    #
    expect(page).to     have_current_path(collectivities_path)
    expect(page).to     have_selector("h1", text: "Collectivités")
    expect(page).not_to have_selector("tr", text: "CA du Pays Basque")
    expect(page).not_to have_selector("tr", text: "Métropole Européenne de Lille")

    expect(page).not_to have_selector("#datatable-collectivities-selection-bar", text: "2 collectivités sélectionnées")
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les collectivités sélectionnées ont été supprimées.")

    # The notification should include a button to cancel the last action
    #
    within "[role=alert]", text: "Les collectivités sélectionnées ont été supprimées." do |alert|
      expect(alert).to have_button("Annuler")

      click_on "Annuler"
    end

    # The browser should stay on index page
    # The remove collectivities should be back again
    #
    # The selection message should not appears again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).to     have_current_path(collectivities_path)
    expect(page).to     have_selector("h1", text: "Collectivités")
    expect(page).to     have_selector("tr", text: "CA du Pays Basque")
    expect(page).to     have_selector("tr", text: "Métropole Européenne de Lille")

    expect(page).not_to have_selector("#datatable-collectivities-selection-bar", text: "2 collectivités sélectionnées")
    expect(page).not_to have_selector("[role=alert]", text: "Les collectivités sélectionnées ont été supprimées.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression des collectivités sélectionnées a été annulée.")
  end
end
