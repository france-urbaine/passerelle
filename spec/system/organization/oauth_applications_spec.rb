# frozen_string_literal: true

require "system_helper"

RSpec.describe "OauthApplications managed by current organization" do
  fixtures :publishers, :users, :oauth_applications

  let(:test_app)         { oauth_applications(:test_app) }
  let(:publisher)        { publishers(:fiscalite_territoire) }
  let(:redirect_uri_app) { oauth_applications(:redirect_uri_app) }

  before { sign_in(users(:elise)) }

  it "visits index & oauth_application pages" do
    visit organization_oauth_applications_path

    # A table of owned oauth_applications should be present
    #
    expect(page).to have_selector("h1", text: "Applications")
    expect(page).to have_link("Test Oauth Application")

    click_on "Test Oauth Application"

    # The browser should visit the oauth_application page
    #
    expect(page).to have_current_path(organization_oauth_application_path(test_app))
    expect(page).to have_selector("h1", text: "Test Oauth Application")

    go_back

    # The browser should redirect back to the index page
    #
    expect(page).to have_current_path(organization_oauth_applications_path)
    expect(page).to have_selector("h1", text: "Applications")
  end

  it "creates an oauth_application from the index page" do
    visit organization_oauth_applications_path

    # A button should be present to add a new oauth_application
    #
    click_on "Ajouter une application"

    # A dialog box should appear with a form to fill
    #
    within "[role=dialog]", text: "Création d'une nouvelle application" do |dialog|
      expect(dialog).to     have_field("Nom de l'application", with: nil)
      expect(dialog).to     have_field("URI de redirection", with: nil)

      fill_in "Nom", with: "Nouvelle App"

      click_on "Enregistrer"
    end

    # The browser should stay on the index page
    # The new oauth_application should appear
    #
    expect(page).to have_current_path(organization_oauth_applications_path)
    expect(page).to have_selector("h1", text: "Applications")
    expect(page).to have_selector(:table_row, "Nom" => "Nouvelle App")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Une nouvelle application a été ajoutée avec succés.")
  end

  it "updates an oauth_application from the index page" do
    visit organization_oauth_applications_path

    # A button should be present to edit the oauth_application
    #
    within :table_row, { "Nom" => "Test Oauth Application" } do
      click_on "Modifier cette application"
    end

    # A dialog box should appear with a form
    # The form should be filled with oauth_application data
    #
    within "[role=dialog]", text: "Modification de l'application" do |dialog|
      expect(dialog).to have_field("Nom", with: "Test Oauth Application")

      fill_in "Nom de l'application", with: "Test Oauth Application 2"
      click_on "Enregistrer"
    end

    # The browser should stay on the index page
    # The oauth_application should have changed its name
    #
    expect(page).to have_current_path(organization_oauth_applications_path)
    expect(page).to have_selector("h1", text: "Applications")
    expect(page).to have_selector(:table_row, "Nom" => "Test Oauth Application 2")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "updates an oauth_application from the oauth_application page" do
    visit organization_oauth_application_path(test_app)

    # A button should be present to edit the oauth_application
    #
    within ".header-bar", text: "Test Oauth Application" do
      click_on "Modifier"
    end

    # A dialog box should appear with a form
    # The form should be filled with oauth_application data
    #
    within "[role=dialog]", text: "Modification de l'application" do |dialog|
      expect(dialog).to     have_field("Nom", with: "Test Oauth Application")

      fill_in "Nom", with: "Test Oauth Application 2"
      click_on "Enregistrer"
    end

    # The browser should stay on show page
    # The oauth_application should have changed its name
    #
    expect(page).to have_current_path(organization_oauth_application_path(test_app))
    expect(page).to have_selector("h1", text: "Test Oauth Application 2")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "discards an oauth_application from the index page & rollbacks" do
    visit organization_oauth_applications_path

    expect(page).to have_text("2 applications | Page 1 sur 1")

    # A button should be present to remove the oauth_application
    #
    within :table_row, { "Nom" => "Test Oauth Application" } do
      click_on "Supprimer cette application"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer cette application ?" do
      click_on "Continuer"
    end

    # The browser should stay on the index page
    # The oauth_application should not appears anymore
    #
    expect(page).to     have_current_path(organization_oauth_applications_path)
    expect(page).to     have_selector("h1", text: "Applications")
    expect(page).to     have_text("1 application | Page 1 sur 1")
    expect(page).not_to have_selector(:table_row, "Nom" => "Test Oauth Application")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "L'application a été supprimée.")

    # The notification should include a button to cancel the last action
    #
    within "[role=alert]", text: "L'application a été supprimée." do
      click_on "Annuler"
    end

    # The browser should stay on the index page
    # The oauth_application should be back again
    #
    expect(page).to have_current_path(organization_oauth_applications_path)
    expect(page).to have_selector("h1", text: "Applications")
    expect(page).to have_text("2 applications | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "Nom" => "Test Oauth Application")

    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector("[role=alert]", text: "L'application a été supprimé.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression de l'application a été annulée.")
  end

  it "discards an oauth_application from the oauth_application page & rollbacks" do
    visit organization_oauth_application_path(test_app)

    # A button should be present to remove the oauth_application
    #
    within ".header-bar", text: "Test Oauth Application" do
      click_on "Supprimer"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer cette application ?" do
      click_on "Continuer"
    end

    # The browser should redirect to the index page
    # The oauth_application should not appears anymore
    #
    expect(page).to     have_current_path(organization_oauth_applications_path)
    expect(page).to     have_selector("h1", text: "Applications")
    expect(page).to     have_text("1 application | Page 1 sur 1")
    expect(page).not_to have_selector(:table_row, "Nom" => "Test Oauth Application")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "L'application a été supprimée.")

    # The notification should include a button to cancel the last action
    #
    within "[role=alert]", text: "L'application a été supprimée." do
      click_on "Annuler"
    end

    # The browser should stay on the index page
    # The oauth_application should be back again
    #
    expect(page).to have_current_path(organization_oauth_applications_path)
    expect(page).to have_selector("h1", text: "Applications")
    expect(page).to have_text("2 applications | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "Nom" => "Test Oauth Application")

    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector("[role=alert]", text: "L'application a été supprimée.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression de l'application a été annulée.")
  end

  it "selects and discards one oauth_application from the index page & rollbacks" do
    visit organization_oauth_applications_path

    expect(page).to have_text("2 applications | Page 1 sur 1")

    # Checkboxes should be present to select oauth_applications
    #
    within :table_row, { "Nom" => "Test Oauth Application" } do
      check
    end

    # A message should diplay the number of selected oauth_applications
    # with a button to remove them
    #
    within ".header-bar--selection", text: "1 application sélectionnée" do
      click_on "Tout supprimer"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer l'application sélectionnée ?" do
      click_on "Continuer"
    end

    # The browser should stay on index page
    # The selected oauth_applications should not appears anymore
    # Other oauth_applications should remain
    #
    expect(page).to     have_current_path(organization_oauth_applications_path)
    expect(page).to     have_selector("h1", text: "Applications")
    expect(page).to     have_text("1 application | Page 1 sur 1")
    expect(page).not_to have_selector(:table_row, "Nom" => "Test Oauth Application")
    expect(page).to     have_selector(:table_row, "Nom" => "Oauth Application with URI")

    # The selection message should not appears anymore
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les applications sélectionnées ont été supprimées.")

    # The notification should include a button to cancel the last action
    #
    within "[role=alert]", text: "Les applications sélectionnées ont été supprimées." do
      click_on "Annuler"
    end

    # The browser should stay on index page
    # The remove oauth_applications should be back again
    #
    expect(page).to have_current_path(organization_oauth_applications_path)
    expect(page).to have_selector("h1", text: "Applications")
    expect(page).to have_text("2 applications | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "Nom" => "Test Oauth Application")

    # The selection message should not appears again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=alert]", text: "Les applications sélectionnées ont été supprimées.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression des applications sélectionnées a été annulée.")
  end

  it "selects and discards all oauth_applications from the current page on index page & rollbacks" do
    # Create a bunch of oauth_applications to have several pages
    # Create discarded oauth_applications to verify they are not rollbacked
    #
    create_list(:oauth_application, 10, owner: publisher)
    create_list(:oauth_application, 5)

    visit organization_oauth_applications_path

    expect(page).to have_text("12 applications | Page 1 sur 1")

    # Paginate oauth_applications by 10
    # More than one page should exist
    #
    click_on "Options d'affichage"
    click_on "Afficher 50 lignes par page"
    click_on "Afficher 10 lignes"

    expect(page).to have_text("12 applications | Page 1 sur 2")

    # Checkboxes should be present to select all oauth_applications
    #
    within :table do
      check nil, match: :first
    end

    # A message should diplay the number of selected oauth_applications
    # with a button to remove them
    #
    within ".header-bar--selection", text: "10 applications sélectionnées" do
      click_on "Tout supprimer"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer les 10 applications sélectionnées ?" do
      click_on "Continuer"
    end

    # The browser should stay on index page
    # The selected oauth_applications should have been removed
    #
    expect(page).to     have_current_path(organization_oauth_applications_path)
    expect(page).to     have_selector("h1", text: "Applications")
    expect(page).to     have_text("2 applications | Page 1 sur 1")
    expect(page).not_to have_selector(:table_row, "Nom" => "Test Oauth Application")
    expect(page).not_to have_selector(:table_row, "Nom" => "Oauth Application with URI")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les applications sélectionnées ont été supprimées.")

    # The notification should include a button to cancel the last action
    #
    within "[role=alert]", text: "Les applications sélectionnées ont été supprimées." do
      click_on "Annuler"
    end

    # The browser should stay on index page
    # All oauth_applications should be back again
    #
    expect(page).to have_current_path(organization_oauth_applications_path)
    expect(page).to have_selector("h1", text: "Applications")
    expect(page).to have_text("2 applications | Page 1 sur 2")
    expect(page).to have_selector(:table_row, "Nom" => "Test Oauth Application")
    expect(page).to have_selector(:table_row, "Nom" => "Oauth Application with URI")

    # The selection message should not appears again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=alert]", text: "Les applications sélectionnées ont été supprimées.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression des applications sélectionnées a été annulée.")
  end

  it "selects and discards all oauth_applications through several pages on index page & rollbacks" do
    # Create a bunch of oauth_applications to have several pages
    # TODO: Create discarded oauth_applications to verify they are not rollbacked
    #
    create_list(:oauth_application, 10, owner: publisher)

    visit organization_oauth_applications_path

    expect(page).to have_text("12 applications | Page 1 sur 1")

    # Paginate oauth_applications by 10
    # More than one page should exist
    #
    click_on "Options d'affichage"
    click_on "Afficher 50 lignes par page"
    click_on "Afficher 10 lignes"

    expect(page).to have_text("12 applications | Page 1 sur 2")

    # Checkboxes should be present to select all oauth_applications
    #
    within :table do
      check nil, match: :first
    end

    # A message should diplay the number of selected oauth_applications
    # A link to select any oauth_applications from any page should be present
    # A link to remove all of them should be present
    #
    within ".header-bar--selection", text: "10 applications sélectionnées" do
      click_on "Sélectionner les 12 applications des 2 pages"
    end

    within ".header-bar--selection", text: "12 applications sélectionnées" do
      click_on "Tout supprimer"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer les 12 applications sélectionnées ?" do
      click_on "Continuer"
    end

    # The browser should stay on index page
    # No oauth_applications should appear anymore
    #
    expect(page).to have_current_path(organization_oauth_applications_path)
    expect(page).to have_selector("h1", text: "Applications")
    expect(page).to have_text("Aucune application disponible.")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les applications sélectionnées ont été supprimées.")

    # The notification should include a button to cancel the last action
    #
    within "[role=alert]", text: "Les applications sélectionnées ont été supprimées." do
      click_on "Annuler"
    end

    # The browser should stay on index page
    # All oauth_applications should be back again
    #
    expect(page).to have_current_path(organization_oauth_applications_path)
    expect(page).to have_selector("h1", text: "Applications")
    expect(page).to have_text("2 applications | Page 1 sur 2")
    expect(page).to have_selector(:table_row, "Nom" => "Test Oauth Application")
    expect(page).to have_selector(:table_row, "Nom" => "Oauth Application with URI")

    # The selection message should not appears again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=alert]", text: "Les applications sélectionnées ont été supprimées.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression des applications sélectionnées a été annulée.")
  end
end
