# frozen_string_literal: true

require "system_helper"

RSpec.describe "Collectivities in admin" do
  fixtures :regions, :departements, :epcis, :communes
  fixtures :collectivities, :publishers, :ddfips, :users

  let(:pays_basque)   { collectivities(:pays_basque) }
  let(:publisher)     { publishers(:fiscalite_territoire) }
  let(:epci)          { epcis(:pays_basque) }

  before { sign_in(users(:marc)) }

  it "visits index & collectivity pages" do
    visit admin_collectivities_path

    # A table of all collectivities should be present
    #
    expect(page).to have_selector("h1", text: "Collectivités")
    expect(page).to have_link("CA du Pays Basque")
    expect(page).to have_link("Métropole Européenne de Lille")
    expect(page).to have_link("Commune de Paris")

    click_on "CA du Pays Basque"

    # The browser should visit the collectivity page
    #
    expect(page).to have_current_path(admin_collectivity_path(pays_basque))
    expect(page).to have_selector("h1", text: "CA du Pays Basque")

    go_back

    # The browser should redirect back to the index page
    #
    expect(page).to have_current_path(admin_collectivities_path)
    expect(page).to have_selector("h1", text: "Collectivités")
  end

  it "visits links on a collectivity page & comes back" do
    visit admin_collectivity_path(pays_basque)

    # On the collectivity page, we expect:
    # - a link to the publisher
    # - a link to the EPCI
    #
    expect(page).to have_selector("h1", text: "CA du Pays Basque")
    expect(page).to have_link("Fiscalité & Territoire")
    expect(page).to have_link("CA du Pays Basque (EPCI)")

    click_on "Fiscalité & Territoire"

    # The browser should visit the publisher page
    #
    expect(page).to have_current_path(admin_publisher_path(publisher))
    expect(page).to have_selector("h1", text: "Fiscalité & Territoire")

    go_back

    # The browser should redirect back to the collectivity page
    #
    expect(page).to have_current_path(admin_collectivity_path(pays_basque))
    expect(page).to have_selector("h1", text: "CA du Pays Basque")

    click_on "CA du Pays Basque (EPCI)"

    # The browser should visit the EPCI page
    #
    expect(page).to have_current_path(territories_epci_path(epci))
    expect(page).to have_selector("h1", text: "CA du Pays Basque")

    go_back

    # The browser should redirect back to the collectivity page
    #
    expect(page).to have_current_path(admin_collectivity_path(pays_basque))
    expect(page).to have_selector("h1", text: "CA du Pays Basque")
  end

  it "creates a collectivity from the index page" do
    visit admin_collectivities_path

    # A button should be present to add a new collectivity
    #
    click_on "Ajouter une collectivité"

    # A dialog box should appear with a form to fill
    #
    within "[role=dialog]", text: "Création d'une nouvelle collectivité" do |dialog|
      expect(dialog).to have_field("Territoire")
      expect(dialog).to have_field("Éditeur")
      expect(dialog).to have_field("Nom de la collectivité")
      expect(dialog).to have_field("Numéro SIREN de la collectivité")
      expect(dialog).to have_field("Prénom du contact")
      expect(dialog).to have_field("Nom du contact")
      expect(dialog).to have_field("Adresse mail de contact")
      expect(dialog).to have_field("Numéro de téléphone")

      fill_in "Territoire", with: "Aix-Marseille"
      select_option "Métropole d'Aix-Marseille-Provence", from: "Territoire"

      select "Fiscalité & Territoire", from: "Éditeur"

      fill_in "Nom de la collectivité",          with: "Métropole d'Aix-Marseille-Provence"
      fill_in "Numéro SIREN de la collectivité", with: "200054807"

      click_on "Enregistrer"
    end

    # The browser should stay on the index page
    # The new collectivity should appear
    #
    expect(page).to have_current_path(admin_collectivities_path)
    expect(page).to have_selector("h1", text: "Collectivités")
    expect(page).to have_selector(:table_row, "Collectivité" => "Métropole d'Aix-Marseille-Provence")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=log]", text: "Une nouvelle collectivité a été ajoutée avec succés.")
  end

  it "updates a collectivity from the index page" do
    visit admin_collectivities_path

    # A button should be present to edit the collectivity
    #
    within :table_row, { "Collectivité" => "CA du Pays Basque" } do
      click_on "Modifier cette collectivité"
    end

    # A dialog box should appear with a form
    # The form should be filled with collectivity data
    #
    within "[role=dialog]", text: "Modification de la collectivité" do |dialog|
      expect(dialog).to have_select("Éditeur",                        selected: "Fiscalité & Territoire")
      expect(dialog).to have_field("Territoire",                      with: "CA du Pays Basque")
      expect(dialog).to have_field("Nom de la collectivité",          with: "CA du Pays Basque")
      expect(dialog).to have_field("Numéro SIREN de la collectivité", with: "200067106")

      fill_in "Nom de la collectivité", with: "Agglomération du Pays Basque"
      click_on "Enregistrer"
    end

    # The browser should stay on the index page
    # The collectivity should have changed its name
    #
    expect(page).to have_current_path(admin_collectivities_path)
    expect(page).to have_selector("h1", text: "Collectivités")
    expect(page).to have_selector(:table_row, "Collectivité" => "Agglomération du Pays Basque")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=log]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "updates a collectivity from the collectivity page" do
    visit admin_collectivity_path(pays_basque)

    # A button should be present to edit the collectivity
    #
    within ".breadcrumbs", text: "CA du Pays Basque" do
      click_on "Modifier"
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

    # The browser should stay on the collectivity page
    # The collectivity should have changed its name
    #
    expect(page).to have_current_path(admin_collectivity_path(pays_basque))
    expect(page).to have_selector("h1", text: "Agglomération du Pays Basque")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=log]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "discards a collectivity from the index page & rollbacks" do
    visit admin_collectivities_path

    expect(page).to have_text("7 collectivités | Page 1 sur 1")

    # A button should be present to remove the collectivity
    #
    within :table_row, { "Collectivité" => "CA du Pays Basque" } do
      click_on "Supprimer cette collectivité"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer cette collectivité ?" do
      click_on "Continuer"
    end

    # The browser should stay on the index page
    # The collectivity should not appears anymore
    #
    expect(page).to     have_current_path(admin_collectivities_path)
    expect(page).to     have_selector("h1", text: "Collectivités")
    expect(page).to     have_text("6 collectivités | Page 1 sur 1")
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

    # The browser should stay on the index page
    # The collectivity should be back again
    #
    expect(page).to have_current_path(admin_collectivities_path)
    expect(page).to have_selector("h1", text: "Collectivités")
    expect(page).to have_text("7 collectivités | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "Collectivité" => "CA du Pays Basque")

    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector("[role=log]", text: "La collectivité a été supprimée.")
    expect(page).to     have_selector("[role=log]", text: "La suppression de la collectivité a été annulée.")
  end

  it "discards a collectivity from the collectivity page & rollbacks" do
    visit admin_collectivity_path(pays_basque)

    # A button should be present to remove the collectivity
    #
    within ".breadcrumbs", text: "CA du Pays Basque" do
      click_on "Supprimer"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer cette collectivité ?" do
      click_on "Continuer"
    end

    # The browser should redirect to the index page
    # The collectivity should not appears anymore
    #
    expect(page).to     have_current_path(admin_collectivities_path)
    expect(page).to     have_selector("h1", text: "Collectivités")
    expect(page).to     have_text("6 collectivités | Page 1 sur 1")
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

    # The browser should stay on the index page
    # The collectivity should be back again
    #
    expect(page).to have_current_path(admin_collectivities_path)
    expect(page).to have_selector("h1", text: "Collectivités")
    expect(page).to have_text("7 collectivités | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "Collectivité" => "CA du Pays Basque")

    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector("[role=log]", text: "La collectivité a été supprimée.")
    expect(page).to     have_selector("[role=log]", text: "La suppression de la collectivité a été annulée.")
  end

  it "selects and discards one collectivity from the index page & rollbacks" do
    visit admin_collectivities_path

    expect(page).to have_text("7 collectivités | Page 1 sur 1")

    # Checkboxes should be present to select collectivities
    #
    within :table_row, { "Collectivité" => "CA du Pays Basque" } do
      check
    end

    # A message should diplay the number of selected collectivities
    # with a button to remove them
    #
    within ".header-bar--selection", text: "1 collectivité sélectionnée" do
      click_on "Tout supprimer"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer la collectivité sélectionnée ?" do
      click_on "Continuer"
    end

    # The browser should stay on index page
    # The selected collectivities should not appears anymore
    # Other collectivities should remain
    #
    expect(page).to     have_current_path(admin_collectivities_path)
    expect(page).to     have_selector("h1", text: "Collectivités")
    expect(page).to     have_text("6 collectivités | Page 1 sur 1")
    expect(page).not_to have_selector(:table_row, "Collectivité" => "CA du Pays Basque")
    expect(page).to     have_selector(:table_row, "Collectivité" => "Métropole Européenne de Lille")
    expect(page).to     have_selector(:table_row, "Collectivité" => "Commune de Paris")

    # The selection message should not appears anymore
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=log]", text: "Les collectivités sélectionnées ont été supprimées.")

    # The notification should include a button to cancel the last action
    #
    within "[role=log]", text: "Les collectivités sélectionnées ont été supprimées." do
      click_on "Annuler"
    end

    # The browser should stay on index page
    # The remove collectivities should be back again
    #
    expect(page).to have_current_path(admin_collectivities_path)
    expect(page).to have_selector("h1", text: "Collectivités")
    expect(page).to have_text("7 collectivités | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "Collectivité" => "CA du Pays Basque")

    # The selection message should not appears again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=log]", text: "Les collectivités sélectionnées ont été supprimées.")
    expect(page).to     have_selector("[role=log]", text: "La suppression des collectivités sélectionnées a été annulée.")
  end

  it "selects and discards all collectivities from the current page on index page & rollbacks" do
    # Create a bunch of collectivities to have several pages
    # Create discarded collectivities to verify they are not rollbacked
    #
    create_list(:collectivity, 10)
    create_list(:collectivity, 5, :discarded)

    visit admin_collectivities_path

    expect(page).to have_text("17 collectivités | Page 1 sur 1")

    # Paginate collectivities by 10
    # More than one page should exist
    #
    click_on "Options d'affichage"
    click_on "Afficher 50 lignes par page"
    click_on "Afficher 10 lignes"

    expect(page).to have_text("17 collectivités | Page 1 sur 2")

    # Checkboxes should be present to select all collectivities
    #
    within :table do
      check nil, match: :first
    end

    # A message should diplay the number of selected collectivities
    # with a button to remove them
    #
    within ".header-bar--selection", text: "10 collectivités sélectionnées" do
      click_on "Tout supprimer"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer les 10 collectivités sélectionnées ?" do
      click_on "Continuer"
    end

    # The browser should stay on index page
    # The selected collectivities should have been removed
    #
    expect(page).to     have_current_path(admin_collectivities_path)
    expect(page).to     have_selector("h1", text: "Collectivités")
    expect(page).to     have_text("7 collectivités | Page 1 sur 1")
    expect(page).not_to have_text("17 collectivités")
    expect(page).not_to have_selector(:table_row, "Collectivité" => "CA du Pays Basque")
    expect(page).not_to have_selector(:table_row, "Collectivité" => "Métropole Européenne de Lille")
    expect(page).not_to have_selector(:table_row, "Collectivité" => "Commune de Paris")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=log]", text: "Les collectivités sélectionnées ont été supprimées.")

    # The notification should include a button to cancel the last action
    #
    within "[role=log]", text: "Les collectivités sélectionnées ont été supprimées." do
      click_on "Annuler"
    end

    # The browser should stay on index page
    # All collectivities should be back again
    #
    expect(page).to have_current_path(admin_collectivities_path)
    expect(page).to have_selector("h1", text: "Collectivités")
    expect(page).to have_text("17 collectivités | Page 1 sur 2")
    expect(page).to have_selector(:table_row, "Collectivité" => "CA du Pays Basque")
    expect(page).to have_selector(:table_row, "Collectivité" => "Métropole Européenne de Lille")
    expect(page).to have_selector(:table_row, "Collectivité" => "Commune de Paris")

    # The selection message should not appears again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=log]", text: "Les collectivités sélectionnées ont été supprimées.")
    expect(page).to     have_selector("[role=log]", text: "La suppression des collectivités sélectionnées a été annulée.")
  end

  it "selects and discards all collectivities through several pages on index page & rollbacks" do
    # Create a bunch of collectivities to have several pages
    # TODO: Create discarded collectivities to verify they are not rollbacked
    #
    create_list(:collectivity, 10)

    visit admin_collectivities_path

    expect(page).to have_text("17 collectivités | Page 1 sur 1")

    # Paginate collectivities by 10
    # More than one page should exist
    #
    click_on "Options d'affichage"
    click_on "Afficher 50 lignes par page"
    click_on "Afficher 10 lignes"

    expect(page).to have_text("17 collectivités | Page 1 sur 2")

    # Checkboxes should be present to select all collectivities
    #
    within :table do
      check nil, match: :first
    end

    # A message should diplay the number of selected collectivities
    # A link to select any collectivities from any page should be present
    # A link to remove all of them should be present
    #
    within ".header-bar--selection", text: "10 collectivités sélectionnées" do
      click_on "Sélectionner les 17 collectivités des 2 pages"
    end

    within ".header-bar--selection", text: "17 collectivités sélectionnées" do
      click_on "Tout supprimer"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer les 17 collectivités sélectionnées ?" do
      click_on "Continuer"
    end

    # The browser should stay on index page
    # No collectivities should appear anymore
    #
    expect(page).to have_current_path(admin_collectivities_path)
    expect(page).to have_selector("h1", text: "Collectivités")
    expect(page).to have_text("Aucune collectivité disponible.")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=log]", text: "Les collectivités sélectionnées ont été supprimées.")

    # The notification should include a button to cancel the last action
    #
    within "[role=log]", text: "Les collectivités sélectionnées ont été supprimées." do
      click_on "Annuler"
    end

    # The browser should stay on index page
    # All collectivities should be back again
    #
    expect(page).to have_current_path(admin_collectivities_path)
    expect(page).to have_selector("h1", text: "Collectivités")
    expect(page).to have_text("7 collectivités | Page 1 sur 2")
    expect(page).to have_selector(:table_row, "Collectivité" => "CA du Pays Basque")
    expect(page).to have_selector(:table_row, "Collectivité" => "Métropole Européenne de Lille")
    expect(page).to have_selector(:table_row, "Collectivité" => "Commune de Paris")

    # The selection message should not appears again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=log]", text: "Les collectivités sélectionnées ont été supprimées.")
    expect(page).to     have_selector("[role=log]", text: "La suppression des collectivités sélectionnées a été annulée.")
  end
end
