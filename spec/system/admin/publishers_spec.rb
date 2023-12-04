# frozen_string_literal: true

require "system_helper"

RSpec.describe "Publishers in admin" do
  fixtures :publishers, :collectivities, :users

  let(:fiscalite_territoire) { publishers(:fiscalite_territoire) }
  let(:pays_basque)          { collectivities(:pays_basque) }

  before { sign_in(users(:marc)) }

  it "visits index & publisher pages" do
    visit admin_publishers_path

    # A table of all publishers should be present
    #
    expect(page).to have_selector("h1", text: "Éditeurs")
    expect(page).to have_link("Fiscalité & Territoire")

    click_on "Fiscalité & Territoire"

    # The browser should visit the publisher page
    #
    expect(page).to have_selector("h1", text: "Fiscalité & Territoire")
    expect(page).to have_current_path(admin_publisher_path(fiscalite_territoire))

    go_back

    # The browser should redirect back to the index page
    #
    expect(page).to have_current_path(admin_publishers_path)
    expect(page).to have_selector("h1", text: "Éditeurs")
  end

  it "visits publisher & audits pages" do
    visit admin_publishers_path
    click_on "Fiscalité & Territoire"

    # The browser should visit the publisher page
    #
    expect(page).to have_current_path(admin_publisher_path(fiscalite_territoire))
    expect(page).to have_selector("a.button", text: "Voir toute l'activité")

    click_on "Voir toute l'activité"

    # The browser should visit the publisher audits page
    #
    expect(page).to have_current_path(admin_publisher_audits_path(fiscalite_territoire))
    expect(page).to have_selector("pre.logs")
  end

  it "creates a publisher from the index page" do
    visit admin_publishers_path

    # A button should be present to add a new publisher
    #
    click_on "Ajouter un éditeur"

    # A dialog box should appear with a form to fill
    #
    within "[role=dialog]", text: "Création d'un nouvel éditeur" do |dialog|
      expect(dialog).to have_field("Nom de l'éditeur")
      expect(dialog).to have_field("Numéro SIREN de l'éditeur")
      expect(dialog).to have_field("Adresse mail de contact")

      fill_in "Nom de l'éditeur",          with: "Solutions & Territoire"
      fill_in "Numéro SIREN de l'éditeur", with: "848905758"
      click_on "Enregistrer"
    end

    # The browser should stay on the index page
    # The new publisher should appear
    #
    expect(page).to     have_current_path(admin_publishers_path)
    expect(page).to     have_selector("h1", text: "Éditeurs")
    expect(page).to have_selector(:table_row, "Éditeur" => "Solutions & Territoire")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=log]", text: "Un nouvel éditeur a été ajouté avec succés.")
  end

  it "updates a publisher from the index page" do
    visit admin_publishers_path

    # A button should be present to edit the publisher
    #
    within :table_row, { "Éditeur" => "Fiscalité & Territoire" } do
      click_on "Modifier cet éditeur"
    end

    # A dialog box should appear with a form
    # The form should be filled with publisher data
    #
    within "[role=dialog]", text: "Modification de l'éditeur" do |dialog|
      expect(dialog).to have_field("Nom de l'éditeur",          with: "Fiscalité & Territoire")
      expect(dialog).to have_field("Numéro SIREN de l'éditeur", with: "511022394")
      expect(dialog).to have_field("Adresse mail de contact")

      fill_in "Nom de l'éditeur", with: "Solutions & Territoire"
      click_on "Enregistrer"
    end

    # The browser should stay on the index page
    # The publisher should have changed its name
    #
    expect(page).to have_current_path(admin_publishers_path)
    expect(page).to have_selector("h1", text: "Éditeurs")
    expect(page).to have_selector(:table_row, "Éditeur" => "Solutions & Territoire")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=log]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "updates a publisher from the publisher page" do
    visit admin_publisher_path(fiscalite_territoire)

    # A button should be present to edit the publisher
    #
    within ".breadcrumbs", text: "Fiscalité & Territoire" do
      click_on "Modifier"
    end

    # A dialog box should appear with a form
    # The form should be filled with publisher data
    #
    within "[role=dialog]", text: "Modification de l'éditeur" do |dialog|
      expect(dialog).to have_field("Nom de l'éditeur",          with: "Fiscalité & Territoire")
      expect(dialog).to have_field("Numéro SIREN de l'éditeur", with: "511022394")
      expect(dialog).to have_field("Adresse mail de contact")

      fill_in "Nom de l'éditeur", with: "Solutions & Territoire"
      click_on "Enregistrer"
    end

    # The browser should stay on the publisher show page
    # The publisher should have changed its name
    #
    expect(page).to have_current_path(admin_publisher_path(fiscalite_territoire))
    expect(page).to have_selector("h1", text: "Solutions & Territoire")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=log]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "discards a publisher from the index page & rollbacks" do
    visit admin_publishers_path

    expect(page).to have_text("2 éditeurs | Page 1 sur 1")

    # A button should be present to remove the publisher
    #
    within :table_row, { "Éditeur" => "Fiscalité & Territoire" } do
      click_on "Supprimer cet éditeur"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer cet éditeur ?" do
      click_on "Continuer"
    end

    # The browser should stay on the index page
    # The publisher should not appears anymore
    #
    expect(page).to     have_current_path(admin_publishers_path)
    expect(page).to     have_selector("h1", text: "Éditeurs")
    expect(page).to     have_text("1 éditeur | Page 1 sur 1")
    expect(page).not_to have_selector(:table_row, "Éditeur" => "Fiscalité & Territoire")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=log]", text: "L'éditeur a été supprimé.")

    # The notification should include a button to cancel the last action
    #
    within "[role=log]", text: "L'éditeur a été supprimé." do
      click_on "Annuler"
    end

    # The browser should stay on the index page
    # The publisher should be back again
    #
    expect(page).to have_current_path(admin_publishers_path)
    expect(page).to have_selector("h1", text: "Éditeurs")
    expect(page).to have_text("2 éditeurs | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "Éditeur" => "Fiscalité & Territoire")

    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector("[role=log]", text: "L'éditeur a été supprimé.")
    expect(page).to     have_selector("[role=log]", text: "La suppression de l'éditeur a été annulée.")
  end

  it "discards a publisher from the publisher page & rollbacks" do
    visit admin_publisher_path(fiscalite_territoire)

    # A button should be present to edit the publisher
    #
    within ".breadcrumbs", text: "Fiscalité & Territoire" do
      click_on "Supprimer"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer cet éditeur ?" do
      click_on "Continuer"
    end

    # The browser should redirect to the index page
    # The publisher should not appears anymore
    #
    expect(page).to     have_current_path(admin_publishers_path)
    expect(page).to     have_selector("h1", text: "Éditeurs")
    expect(page).to     have_text("1 éditeur | Page 1 sur 1")
    expect(page).not_to have_selector(:table_row, "Éditeur" => "Fiscalité & Territoire")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=log]", text: "L'éditeur a été supprimé.")

    # The notification should include a button to cancel the last action
    #
    within "[role=log]", text: "L'éditeur a été supprimé." do
      click_on "Annuler"
    end

    # The browser should stay on the index page
    # The publisher should be back again
    #
    expect(page).to have_current_path(admin_publishers_path)
    expect(page).to have_selector("h1", text: "Éditeurs")
    expect(page).to have_text("2 éditeurs | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "Éditeur" => "Fiscalité & Territoire")

    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector("[role=log]", text: "L'éditeur a été supprimé.")
    expect(page).to     have_selector("[role=log]", text: "La suppression de l'éditeur a été annulée.")
  end

  it "selects and discards one publisher from the index page & rollbacks" do
    visit admin_publishers_path

    expect(page).to have_text("2 éditeurs | Page 1 sur 1")

    # Checkboxes should be present to select publishers
    #
    within :table_row, { "Éditeur" => "France Urbaine" } do
      check
    end

    # A message should diplay the number of selected publishers
    # with a button to remove them
    #
    within ".datatable__selection", text: "1 éditeur sélectionné" do
      click_on "Tout supprimer"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer l'éditeur sélectionné ?" do
      click_on "Continuer"
    end

    # The browser should stay on index page
    # The selected publishers should not appears anymore
    # Other publishers should remain
    #
    expect(page).to     have_current_path(admin_publishers_path)
    expect(page).to     have_selector("h1", text: "Éditeurs")
    expect(page).to     have_text("1 éditeur | Page 1 sur 1")
    expect(page).not_to have_selector(:table_row, "Éditeur" => "France Urbaine")
    expect(page).to     have_selector(:table_row, "Éditeur" => "Fiscalité & Territoire")

    # The selection message should not appears anymore
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector(".datatable__selection")
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=log]", text: "Les éditeurs sélectionnés ont été supprimés.")

    # The notification should include a button to cancel the last action
    #
    within "[role=log]", text: "Les éditeurs sélectionnés ont été supprimés." do
      click_on "Annuler"
    end

    # The browser should stay on index page
    # The remove publishers should be back again
    #
    expect(page).to have_current_path(admin_publishers_path)
    expect(page).to have_selector("h1", text: "Éditeurs")
    expect(page).to have_text("2 éditeurs | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "Éditeur" => "France Urbaine")

    # The selection message should not appears again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector(".datatable__selection")
    expect(page).not_to have_selector("[role=log]", text: "Les éditeurs sélectionnés ont été supprimés.")
    expect(page).to     have_selector("[role=log]", text: "La suppression des éditeurs sélectionnés a été annulée.")
  end

  it "selects and discards all publishers from the current page on index page & rollbacks" do
    # Create a bunch of publishers to have several pages
    # Create discarded publishers to verify they are not rollbacked
    #
    create_list(:publisher, 10)
    create_list(:publisher, 5, :discarded)

    visit admin_publishers_path

    expect(page).to have_text("12 éditeurs | Page 1 sur 1")

    # Paginate publishers by 10
    # More than one page should exist
    #
    click_on "Options d'affichage"
    click_on "Afficher 50 lignes par page"
    click_on "Afficher 10 lignes"

    expect(page).to have_text("12 éditeurs | Page 1 sur 2")

    # Checkboxes should be present to select all publishers
    #
    within :table do
      check nil, match: :first
    end

    # A message should diplay the number of selected publishers
    # with a button to remove them
    #
    within ".datatable__selection", text: "10 éditeurs sélectionnés" do
      click_on "Tout supprimer"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer les 10 éditeurs sélectionnés ?" do
      click_on "Continuer"
    end

    # The browser should stay on index page
    # The selected publishers should have been removed
    # The current publisher should remains
    #
    expect(page).to     have_current_path(admin_publishers_path)
    expect(page).to     have_selector("h1", text: "Éditeurs")
    expect(page).to     have_text("3 éditeurs | Page 1 sur 1")
    expect(page).to     have_selector(:table_row, "Éditeur" => "Fiscalité & Territoire")
    expect(page).not_to have_selector(:table_row, "Éditeur" => "France Urbaine")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector(".datatable__selection")
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=log]", text: "Les éditeurs sélectionnés ont été supprimés.")

    # The notification should include a button to cancel the last action
    #
    within "[role=log]", text: "Les éditeurs sélectionnés ont été supprimés." do
      click_on "Annuler"
    end

    # The browser should stay on index page
    # All publishers should be back again
    #
    expect(page).to have_current_path(admin_publishers_path)
    expect(page).to have_selector("h1", text: "Éditeurs")
    expect(page).to have_text("12 éditeurs | Page 1 sur 2")
    expect(page).to have_selector(:table_row, "Éditeur" => "Fiscalité & Territoire")
    expect(page).to have_selector(:table_row, "Éditeur" => "France Urbaine")

    # The selection message should not appears again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector(".datatable__selection")
    expect(page).not_to have_selector("[role=log]", text: "Les éditeurs sélectionnés ont été supprimés.")
    expect(page).to     have_selector("[role=log]", text: "La suppression des éditeurs sélectionnés a été annulée.")
  end

  it "selects and discards all publishers through several pages on index page & rollbacks" do
    # Create a bunch of publishers to have several pages
    # TODO: Create discarded publishers to verify they are not rollbacked
    #
    create_list(:publisher, 10)

    visit admin_publishers_path

    expect(page).to have_text("12 éditeurs | Page 1 sur 1")

    # Paginate publishers by 10
    # More than one page should exist
    #
    click_on "Options d'affichage"
    click_on "Afficher 50 lignes par page"
    click_on "Afficher 10 lignes"

    expect(page).to have_text("12 éditeurs | Page 1 sur 2")

    # Checkboxes should be present to select all publishers
    #
    within :table do
      check nil, match: :first
    end

    # A message should diplay the number of selected publishers
    # A link to select any publishers from any page should be present
    # A link to remove all of them should be present
    #
    within ".datatable__selection", text: "10 éditeurs sélectionnés" do
      click_on "Sélectionner les 12 éditeurs des 2 pages"
    end

    within ".datatable__selection", text: "12 éditeurs sélectionnés" do
      click_on "Tout supprimer"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer les 12 éditeurs sélectionnés ?" do
      click_on "Continuer"
    end

    # The browser should stay on index page
    # Only the current publisher should remain
    #
    expect(page).to have_current_path(admin_publishers_path)
    expect(page).to have_selector("h1", text: "Éditeurs")
    expect(page).to have_text("1 éditeur | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "Éditeur" => "Fiscalité & Territoire")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector(".datatable__selection")
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=log]", text: "Les éditeurs sélectionnés ont été supprimés.")

    # The notification should include a button to cancel the last action
    #
    within "[role=log]", text: "Les éditeurs sélectionnés ont été supprimés." do
      click_on "Annuler"
    end

    # The browser should stay on index page
    # All publishers should be back again
    #
    expect(page).to have_current_path(admin_publishers_path)
    expect(page).to have_selector("h1", text: "Éditeurs")
    expect(page).to have_text("12 éditeurs | Page 1 sur 2")
    expect(page).to have_selector(:table_row, "Éditeur" => "Fiscalité & Territoire")
    expect(page).to have_selector(:table_row, "Éditeur" => "France Urbaine")

    # The selection message should not appears again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector(".datatable__selection")
    expect(page).not_to have_selector("[role=log]", text: "Les éditeurs sélectionnés ont été supprimés.")
    expect(page).to     have_selector("[role=log]", text: "La suppression des éditeurs sélectionnés a été annulée.")
  end
end
