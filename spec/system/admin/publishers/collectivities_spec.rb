# frozen_string_literal: true

require "system_helper"

RSpec.describe "Publisher collectivities in admin" do
  fixtures :regions, :departements, :epcis, :communes
  fixtures :publishers, :collectivities, :users

  let(:fiscalite_territoire) { publishers(:fiscalite_territoire) }
  let(:pays_basque)          { collectivities(:pays_basque) }
  let(:epci)                 { epcis(:pays_basque) }

  before { sign_in(users(:marc)) }

  it "visits a collectivity page from the publisher page" do
    visit admin_publisher_path(fiscalite_territoire)

    # A table of collectivities should be present
    #
    expect(page).to have_selector("h1", text: "Fiscalité & Territoire")
    expect(page).to have_selector(:table_row, "Collectivité" => "CA du Pays Basque")
    expect(page).to have_selector(:table_row, "Collectivité" => "Bayonne")

    click_on "CA du Pays Basque"

    # The browser should visit the collectivity page
    #
    expect(page).to have_current_path(admin_collectivity_path(pays_basque))
    expect(page).to have_selector("h1", text: "CA du Pays Basque")

    go_back

    # The browser should gone back to the publisher page
    #
    expect(page).to have_current_path(admin_publisher_path(fiscalite_territoire))
    expect(page).to have_selector("h1", text: "Fiscalité & Territoire")
  end

  it "paginate collectivities on the publisher page" do
    # Create enough collectivities to have several pages
    #
    create_list(:collectivity, 10, publisher: fiscalite_territoire)

    visit admin_publisher_path(fiscalite_territoire)

    expect(page).to     have_text("16 collectivités | Page 1 sur 2")
    expect(page).not_to have_button("Options d'affichage")
  end

  it "creates a collectivity from the publisher page" do
    visit admin_publisher_path(fiscalite_territoire)

    # A button should be present to add a new collectivity
    #
    click_on "Ajouter une collectivité"

    # A dialog box should appear with a form to fill
    #
    within "[role=dialog]", text: "Création d'une nouvelle collectivité" do |dialog|
      expect(dialog).not_to have_select("Éditeur")

      expect(dialog).to have_field("Territoire")
      expect(dialog).to have_field("Nom de la collectivité")
      expect(dialog).to have_field("Numéro SIREN de la collectivité")
      expect(dialog).to have_field("Prénom du contact")
      expect(dialog).to have_field("Nom du contact")
      expect(dialog).to have_field("Adresse mail de contact")
      expect(dialog).to have_field("Numéro de téléphone")

      fill_in "Territoire", with: "Aix-Marseille"
      select_option "Métropole d'Aix-Marseille-Provence", from: "Territoire"

      fill_in "Nom de la collectivité",          with: "Métropole d'Aix-Marseille-Provence"
      fill_in "Numéro SIREN de la collectivité", with: "200054807"

      click_on "Enregistrer"
    end

    # The browser should stay on the publisher page
    # The new collectivity should appear
    #
    expect(page).to have_current_path(admin_publisher_path(fiscalite_territoire))
    expect(page).to have_selector("h1", text: "Fiscalité & Territoire")
    expect(page).to have_selector(:table_row, "Collectivité" => "Métropole d'Aix-Marseille-Provence")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=log]", text: "Une nouvelle collectivité a été ajoutée avec succés.")
  end

  it "updates a collectivity from the publisher page" do
    visit admin_publisher_path(fiscalite_territoire)

    # A table of collectivities should be present
    # with a button to edit them
    #
    within :table_row, { "Collectivité" => "CA du Pays Basque" } do
      click_on "Modifier cette collectivité"
    end

    # A dialog box should appear with a form
    # The form should be filled with collectivity data
    #
    within "[role=dialog]", text: "Modification de la collectivité" do |dialog|
      expect(dialog).to have_field("Territoire",                      with: "CA du Pays Basque")
      expect(dialog).to have_select("Éditeur",                        selected: "Fiscalité & Territoire")
      expect(dialog).to have_field("Nom de la collectivité",          with: "CA du Pays Basque")
      expect(dialog).to have_field("Numéro SIREN de la collectivité", with: "200067106")

      fill_in "Nom de la collectivité", with: "Agglomération du Pays Basque"
      click_on "Enregistrer"
    end

    # The browser should stay on the publisher page
    # The collectivity's name should have been updated
    #
    expect(page).to have_current_path(admin_publisher_path(fiscalite_territoire))
    expect(page).to have_selector("h1", text: "Fiscalité & Territoire")
    expect(page).to have_selector(:table_row, "Collectivité" => "Agglomération du Pays Basque")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=log]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "discards a collectivity from the publisher page & rollbacks" do
    visit admin_publisher_path(fiscalite_territoire)

    expect(page).to have_text("6 collectivités | Page 1 sur 1")

    # A table of collectivities should be present
    # with a button to remove them
    #
    within :table_row, { "Collectivité" => "CA du Pays Basque" } do
      click_on "Supprimer cette collectivité"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer cette collectivité ?" do
      click_on "Continuer"
    end

    # The browser should stay on the publisher page
    # The collectivity should not appears anymore
    #
    expect(page).to     have_current_path(admin_publisher_path(fiscalite_territoire))
    expect(page).to     have_selector("h1", text: "Fiscalité & Territoire")
    expect(page).to     have_text("5 collectivités | Page 1 sur 1")
    expect(page).not_to have_selector(:table_row, "Collectivité" => "CA du Pays Basque")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=log]", text: "La collectivité a été supprimée.")

    # The notification should include a button to cancel the last action
    #
    within "[role=log]", text: "La collectivité a été supprimée." do
      click_on "Annuler"
    end

    # The browser should stay on the publisher page
    # The collectivity should be back again
    #
    expect(page).to have_current_path(admin_publisher_path(fiscalite_territoire))
    expect(page).to have_selector("h1", text: "Fiscalité & Territoire")
    expect(page).to have_text("6 collectivités | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "Collectivité" => "CA du Pays Basque")

    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector("[role=log]", text: "La collectivité a été supprimée.")
    expect(page).to     have_selector("[role=log]", text: "La suppression de la collectivité a été annulée.")
  end

  it "selects and discards one collectivity from the publisher page & rollbacks" do
    visit admin_publisher_path(fiscalite_territoire)

    expect(page).to have_text("6 collectivités | Page 1 sur 1")

    # Some checkboxes should be present to select collectivities
    #
    within :table_row, { "Collectivité" => "CA du Pays Basque" } do
      check
    end

    # A message should diplay the number of selected collectivities
    # with a button to remove them
    #
    within ".datatable__selection", text: "1 collectivité sélectionnée" do
      click_on "Tout supprimer"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer la collectivité sélectionnée ?" do
      click_on "Continuer"
    end

    # The browser should stay on the publisher page
    # The selected collectivities should not appears anymore
    #
    expect(page).to     have_current_path(admin_publisher_path(fiscalite_territoire))
    expect(page).to     have_selector("h1", text: "Fiscalité & Territoire")
    expect(page).to     have_text("5 collectivités | Page 1 sur 1")
    expect(page).not_to have_selector(:table_row, "Collectivité" => "CA du Pays Basque")

    # The selection message should not appears anymore
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector(".datatable__selection")
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=log]", text: "Les collectivités sélectionnées ont été supprimées.")

    # The notification should include a button to cancel the last action
    #
    within "[role=log]", text: "Les collectivités sélectionnées ont été supprimées." do
      click_on "Annuler"
    end

    # The browser should stay on the publisher page
    # The removed collectivities should be back again
    #
    expect(page).to have_current_path(admin_publisher_path(fiscalite_territoire))
    expect(page).to have_selector("h1", text: "Fiscalité & Territoire")
    expect(page).to have_text("6 collectivités | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "Collectivité" => "CA du Pays Basque")

    # The selection message should not appears again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector(".datatable__selection")
    expect(page).not_to have_selector("[role=log]", text: "Les collectivités sélectionnées ont été supprimées.")
    expect(page).to     have_selector("[role=log]", text: "La suppression des collectivités sélectionnées a été annulée.")
  end

  it "selects and discards all collectivities from the current page on the publisher page & rollbacks" do
    # Create a bunch of collectivities to have several pages
    # Also create discarded collectivities on other organizations to ensure there are not rollbacked
    #
    create_list(:collectivity, 10, publisher: fiscalite_territoire)
    create_list(:collectivity, 5, :discarded)

    visit admin_publisher_path(fiscalite_territoire)

    expect(page).to have_text("16 collectivités | Page 1 sur 2")

    # Checkboxes should be present to select all collectivities
    #
    within "#datatable-collectivities" do
      check nil, match: :first
    end

    # A message should diplay the number of selected collectivities
    # with a button to remove them
    #
    within ".datatable__selection", text: "10 collectivités sélectionnées" do
      click_on "Tout supprimer"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer les 10 collectivités sélectionnées ?" do
      click_on "Continuer"
    end

    # The browser should stay on the publisher page
    # The selected collectivities should have been removed
    #
    expect(page).to     have_current_path(admin_publisher_path(fiscalite_territoire))
    expect(page).to     have_selector("h1", text: "Fiscalité & Territoire")
    expect(page).to     have_text("6 collectivités | Page 1 sur 1")
    expect(page).not_to have_text("16 collectivités")
    expect(page).not_to have_selector(:table_row, "Collectivité" => "CA du Pays Basque")
    expect(page).not_to have_selector(:table_row, "Collectivité" => "Métropole Européenne de Lille")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector(".datatable__selection")
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=log]", text: "Les collectivités sélectionnées ont été supprimées.")

    # The notification should include a button to cancel the last action
    #
    within "[role=log]", text: "Les collectivités sélectionnées ont été supprimées." do
      click_on "Annuler"
    end

    # The browser should stay on the publisher page
    # The removed collectivities should be back again
    #
    expect(page).to have_current_path(admin_publisher_path(fiscalite_territoire))
    expect(page).to have_selector("h1", text: "Fiscalité & Territoire")
    expect(page).to have_text("16 collectivités | Page 1 sur 2")
    expect(page).to have_selector(:table_row, "Collectivité" => "CA du Pays Basque")
    expect(page).to have_selector(:table_row, "Collectivité" => "Métropole Européenne de Lille")

    expect(Collectivity.discarded.count).to eq(5)

    # The selection message should not appears again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector(".datatable__selection")
    expect(page).not_to have_selector("[role=log]", text: "Les collectivités sélectionnées ont été supprimées.")
    expect(page).to     have_selector("[role=log]", text: "La suppression des collectivités sélectionnées a été annulée.")
  end

  it "selects and discards all collectivities through several pages on the publisher page & rollbacks" do
    # Create a bunch of collectivities to have several pages
    # Also create discarded collectivities on other organizations to ensure there are not rollbacked
    #
    create_list(:collectivity, 10, publisher: fiscalite_territoire)
    create_list(:collectivity, 5, :discarded)

    visit admin_publisher_path(fiscalite_territoire)

    expect(page).to have_text("16 collectivités | Page 1 sur 2")

    # Checkboxes should be present to select all collectivities
    #
    within "#datatable-collectivities" do
      check nil, match: :first
    end

    # A message should diplay the number of selected collectivities
    # with a button to remove them
    #
    within ".datatable__selection", text: "10 collectivités sélectionnées" do
      click_on "Sélectionner les 16 collectivités des 2 pages"
    end

    within ".datatable__selection", text: "16 collectivités sélectionnées" do
      click_on "Tout supprimer"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer les 16 collectivités sélectionnées ?" do
      click_on "Continuer"
    end

    # The browser should stay on the publisher page
    # No collectivities should appear anymore
    # Other collectivities from other organizations should remain
    #
    expect(page).to have_current_path(admin_publisher_path(fiscalite_territoire))
    expect(page).to have_selector("h1", text: "Fiscalité & Territoire")
    expect(page).to have_text("Aucune collectivité enregistrée.")

    expect(Collectivity.discarded.count).to eq(21)

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector(".datatable__selection")
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=log]", text: "Les collectivités sélectionnées ont été supprimées.")

    # The notification should include a button to cancel the last action
    #
    within "[role=log]", text: "Les collectivités sélectionnées ont été supprimées." do
      click_on "Annuler"
    end

    # The browser should stay on the publisher page
    # The removed collectivities should be back again
    #
    expect(page).to have_current_path(admin_publisher_path(fiscalite_territoire))
    expect(page).to have_selector("h1", text: "Fiscalité & Territoire")
    expect(page).to have_text("16 collectivités | Page 1 sur 2")
    expect(page).to have_selector(:table_row, "Collectivité" => "CA du Pays Basque")
    expect(page).to have_selector(:table_row, "Collectivité" => "Métropole Européenne de Lille")

    expect(Collectivity.discarded.count).to eq(5)

    # The selection message should not appears again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector(".datatable__selection")
    expect(page).not_to have_selector("[role=log]", text: "Les collectivités sélectionnées ont été supprimées.")
    expect(page).to     have_selector("[role=log]", text: "La suppression des collectivités sélectionnées a été annulée.")
  end
end
