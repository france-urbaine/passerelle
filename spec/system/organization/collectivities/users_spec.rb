# frozen_string_literal: true

require "system_helper"

RSpec.describe "Manage users of collectivities managed by current organization" do
  fixtures :all

  let(:pays_basque) { collectivities(:pays_basque) }
  let(:christelle)  { users(:christelle) }
  let(:pierre)      { users(:pierre) }

  before { sign_in(users(:marc)) }

  it "visits collectity and one of its users pages" do
    visit organization_collectivity_path(pays_basque)

    # A table of all collectivity users should be present
    #
    expect(page).to have_selector("h1", text: "CA du Pays Basque")
    expect(page).to have_text("2 utilisateurs | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Christelle Droitier")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Pierre Civil")

    click_on "Christelle Droitier"

    # The browser should visit the user page
    #
    expect(page).to have_current_path(organization_collectivity_user_path(pays_basque, christelle))
    expect(page).to have_selector("h1", text: "Christelle Droitier")

    go_back

    # The browser should redirect back to the collectivity page
    #
    expect(page).to have_current_path(organization_collectivity_path(pays_basque))
    expect(page).to have_selector("h1", text: "CA du Pays Basque")
  end

  it "visits a collectivity user page" do
    visit organization_collectivity_user_path(pays_basque, christelle)

    # On the user page, we expect only one email link.
    #
    expect(page).to have_selector("h1", text: "Christelle Droitier")
    expect(page).to have_link("christelle.droitier@paysbasque.fr")
  end

  it "invites an user from the collectity page" do
    visit organization_collectivity_path(pays_basque)

    # A button should be present to add a new user
    #
    click_on "Inviter un utilisateur"

    # A dialog box should appear with a form to fill
    #
    within "[role=dialog]", text: "Invitation d'un nouvel utilisateur" do |dialog|
      expect(dialog).not_to have_field("Organisation")
      expect(dialog).to have_field("Prénom")
      expect(dialog).to have_field("Nom")
      expect(dialog).to have_field("Adresse mail")
      expect(dialog).to have_unchecked_field("Administrateur de l'organisation")

      # Fill the form with invalid data
      #
      fill_in "Prénom",       with: "  "
      fill_in "Nom",          with: "  "
      fill_in "Adresse mail", with: "  "

      click_on "Enregistrer"

      # Errors must be displayed
      #
      expect(dialog).to have_selector(".form-block__errors", text: "Un prénom est requis")
      expect(dialog).to have_selector(".form-block__errors", text: "Un nom est requis")
      expect(dialog).to have_selector(".form-block__errors", text: "Une adresse mail est requise")

      # Fill the form with valid data
      #
      fill_in "Prénom",       with: "Elliot"
      fill_in "Nom",          with: "Alderson"
      fill_in "Adresse mail", with: "robot@fiscalite-territoire.fr"

      click_on "Enregistrer"
    end

    # The browser should stay on the collectivity page
    # The new user should appear
    #
    expect(page).to have_current_path(organization_collectivity_path(pays_basque))
    expect(page).to have_selector("h1", text: "CA du Pays Basque")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Elliot Alderson")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Un nouvel utilisateur a été ajouté avec succés.")
  end

  it "updates an user from the collectivity page" do
    visit organization_collectivity_path(pays_basque)

    # A button should be present to edit the user
    #
    within :table_row, { "Utilisateur" => "Pierre Civil" } do
      click_on "Modifier cet utilisateur"
    end

    # A dialog box should appear with a form
    # The form should be filled with user data
    #
    within "[role=dialog]", text: "Modification de l'utilisateur" do |dialog|
      expect(dialog).not_to have_field("Organisation")
      expect(dialog).to have_field("Prénom",       with: "Pierre")
      expect(dialog).to have_field("Nom",          with: "Civil")
      expect(dialog).to have_field("Adresse mail", with: "pierre.civil@paysbasque.fr")
      expect(dialog).to have_unchecked_field("Administrateur de l'organisation")

      # Fill the form with invalid data
      #
      fill_in "Prénom", with: "  "
      fill_in "Nom",    with: "  "

      click_on "Enregistrer"

      # Errors must be displayed
      #
      expect(dialog).to have_selector(".form-block__errors", text: "Un prénom est requis")
      expect(dialog).to have_selector(".form-block__errors", text: "Un nom est requis")

      # Fill the form with valid data
      #
      fill_in "Prénom", with: "Jean-Pierre"
      fill_in "Nom",    with: "Livic"

      click_on "Enregistrer"
    end

    # The browser should stay on the collectivity page
    # The user should have changed its name
    #
    expect(page).to have_current_path(organization_collectivity_path(pays_basque))
    expect(page).to have_selector("h1", text: "CA du Pays Basque")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Jean-Pierre Livic")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "updates an user from the user page" do
    visit organization_collectivity_user_path(pays_basque, pierre)

    # A button should be present to edit the user
    #
    within ".header-bar", text: "Pierre Civil" do
      click_on "Modifier"
    end

    # A dialog box should appear with a form
    # The form should be filled with user data
    #
    within "[role=dialog]", text: "Modification de l'utilisateur" do |dialog|
      expect(dialog).not_to have_field("Organisation")
      expect(dialog).to have_field("Prénom",       with: "Pierre")
      expect(dialog).to have_field("Nom",          with: "Civil")
      expect(dialog).to have_field("Adresse mail", with: "pierre.civil@paysbasque.fr")
      expect(dialog).to have_unchecked_field("Administrateur de l'organisation")

      # Fill the form with invalid data
      #
      fill_in "Prénom", with: "  "
      fill_in "Nom",    with: "  "

      click_on "Enregistrer"

      # Errors must be displayed
      #
      expect(dialog).to have_selector(".form-block__errors", text: "Un prénom est requis")
      expect(dialog).to have_selector(".form-block__errors", text: "Un nom est requis")

      # Fill the form with valid data
      #
      fill_in "Prénom", with: "Jean-Pierre"
      fill_in "Nom",    with: "Livic"

      click_on "Enregistrer"
    end

    # The browser should stay on the user page
    # The user should have changed its name
    #
    expect(page).to have_current_path(organization_collectivity_user_path(pays_basque, pierre))
    expect(page).to have_selector("h1", text: "Jean-Pierre Livic")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "discards an user from the collectivity page & rollbacks" do
    visit organization_collectivity_path(pays_basque)

    expect(page).to have_text("2 utilisateurs | Page 1 sur 1")

    # A button should be present to remove the user
    #
    within :table_row, { "Utilisateur" => "Pierre Civil" } do
      click_on "Supprimer cet utilisateur"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer cet utilisateur ?" do
      click_on "Continuer"
    end

    # The browser should stay on the collectivity page
    # The user should not appears anymore
    #
    expect(page).to     have_current_path(organization_collectivity_path(pays_basque))
    expect(page).to     have_selector("h1", text: "CA du Pays Basque")
    expect(page).to     have_text("1 utilisateur | Page 1 sur 1")
    expect(page).not_to have_selector(:table_row, "Utilisateur" => "Pierre Civil")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "L'utilisateur a été supprimé.")

    # The notification should include a button to cancel the last action
    #
    within "[role=alert]", text: "L'utilisateur a été supprimé." do
      click_on "Annuler"
    end

    # The browser should stay on the collectivity page
    # The user should be back again
    #
    expect(page).to have_current_path(organization_collectivity_path(pays_basque))
    expect(page).to have_selector("h1", text: "CA du Pays Basque")
    expect(page).to have_text("2 utilisateurs | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Pierre Civil")

    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector("[role=alert]", text: "L'utilisateur a été supprimé.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression de l'utilisateur a été annulée.")
  end

  it "discards an user from the user page & rollbacks" do
    visit organization_collectivity_user_path(pays_basque, pierre)

    # A button should be present to edit the user
    #
    within ".header-bar", text: "Pierre Civil" do
      click_on "Supprimer"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer cet utilisateur ?" do
      click_on "Continuer"
    end

    # The browser should redirect to the collectivity page
    # The user should not appears anymore
    #
    expect(page).to     have_current_path(organization_collectivity_path(pays_basque))
    expect(page).to     have_selector("h1", text: "CA du Pays Basque")
    expect(page).to     have_text("1 utilisateur | Page 1 sur 1")
    expect(page).not_to have_selector(:table_row, "Utilisateur" => "Pierre Civil")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "L'utilisateur a été supprimé.")

    # The notification should include a button to cancel the last action
    #
    within "[role=alert]", text: "L'utilisateur a été supprimé." do
      click_on "Annuler"
    end

    # The browser should stay on the collectivity page
    # The user should be back again
    #
    expect(page).to have_current_path(organization_collectivity_path(pays_basque))
    expect(page).to have_selector("h1", text: "CA du Pays Basque")
    expect(page).to have_text("2 utilisateurs | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Pierre Civil")

    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector("[role=alert]", text: "L'utilisateur a été supprimé.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression de l'utilisateur a été annulée.")
  end

  it "selects and discards one user from the collectivity page & rollbacks" do
    visit organization_collectivity_path(pays_basque)

    expect(page).to have_text("2 utilisateurs | Page 1 sur 1")

    # Checkboxes should be present to select users
    #
    within :table_row, { "Utilisateur" => "Pierre Civil" } do
      check
    end

    # A message should diplay the number of selected users
    # with a button to remove them
    #
    within ".header-bar--selection", text: "1 utilisateur sélectionné" do
      click_on "Tout supprimer"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer l'utilisateur sélectionné ?" do
      click_on "Continuer"
    end

    # The browser should stay on collectivity page
    # The selected users should not appears anymore
    # Other users should remain
    #
    expect(page).to     have_current_path(organization_collectivity_path(pays_basque))
    expect(page).to     have_selector("h1", text: "CA du Pays Basque")
    expect(page).to     have_text("1 utilisateur | Page 1 sur 1")
    expect(page).not_to have_selector(:table_row, "Utilisateur" => "Pierre Civil")
    expect(page).to     have_selector(:table_row, "Utilisateur" => "Christelle Droitier")

    # The selection message should not appears anymore
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les utilisateurs sélectionnés ont été supprimés.")

    # The notification should include a button to cancel the last action
    #
    within "[role=alert]", text: "Les utilisateurs sélectionnés ont été supprimés." do
      click_on "Annuler"
    end

    # The browser should stay on collectivity page
    # The remove users should be back again
    #
    expect(page).to have_current_path(organization_collectivity_path(pays_basque))
    expect(page).to have_selector("h1", text: "CA du Pays Basque")
    expect(page).to have_text("2 utilisateurs | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Pierre Civil")

    # The selection message should not appears again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=alert]", text: "Les utilisateurs sélectionnés ont été supprimés.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression des utilisateurs sélectionnés a été annulée.")
  end

  it "selects and discards all users from the current page on collectivity page & rollbacks" do
    # Create a bunch of users to have several pages
    # Create discarded users to verify they are not rollbacked
    #
    create_list(:user, 10, organization: pays_basque)
    create_list(:user, 5, :discarded, organization: pays_basque)

    visit organization_collectivity_path(pays_basque)

    expect(page).to have_text("12 utilisateurs | Page 1 sur 1")

    # Paginate users by 10
    # More than one page should exist
    #
    click_on "Options d'affichage"
    click_on "Afficher 50 lignes par page"
    click_on "Afficher 10 lignes"

    expect(page).to have_text("12 utilisateurs | Page 1 sur 2")

    # Checkboxes should be present to select all users
    #
    within :table do
      check nil, match: :first
    end

    # A message should diplay the number of selected users
    # with a button to remove them
    #
    within ".header-bar--selection", text: "10 utilisateurs sélectionnés" do
      click_on "Tout supprimer"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer les 10 utilisateurs sélectionnés ?" do
      click_on "Continuer"
    end

    # The browser should stay on collectivity page
    # The selected users should have been removed
    #
    expect(page).to     have_current_path(organization_collectivity_path(pays_basque))
    expect(page).to     have_selector("h1", text: "CA du Pays Basque")
    expect(page).to     have_text("2 utilisateurs | Page 1 sur 1")
    expect(page).not_to have_selector(:table_row, "Utilisateur" => "Pierre Civil")
    expect(page).not_to have_selector(:table_row, "Utilisateur" => "Christelle Droitier")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les utilisateurs sélectionnés ont été supprimés.")

    # The notification should include a button to cancel the last action
    #
    within "[role=alert]", text: "Les utilisateurs sélectionnés ont été supprimés." do
      click_on "Annuler"
    end

    # The browser should stay on collectivity page
    # All users should be back again
    #
    expect(page).to have_current_path(organization_collectivity_path(pays_basque))
    expect(page).to have_selector("h1", text: "CA du Pays Basque")
    expect(page).to have_text("12 utilisateurs | Page 1 sur 2")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Pierre Civil")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Christelle Droitier")

    # The selection message should not appears again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=alert]", text: "Les utilisateurs sélectionnés ont été supprimés.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression des utilisateurs sélectionnés a été annulée.")
  end

  it "selects and discards all users through several pages on collectivity page and been disconnected" do
    # Create a bunch of users to have several pages
    # TODO: Create discarded users to verify they are not rollbacked
    #
    create_list(:user, 10, organization: pays_basque)

    visit organization_collectivity_path(pays_basque)

    expect(page).to have_text("12 utilisateurs | Page 1 sur 1")

    # Paginate users by 10
    # More than one page should exist
    #
    click_on "Options d'affichage"
    click_on "Afficher 50 lignes par page"
    click_on "Afficher 10 lignes"

    expect(page).to have_text("12 utilisateurs | Page 1 sur 2")

    # Checkboxes should be present to select all users
    #
    within :table do
      check nil, match: :first
    end

    # A message should diplay the number of selected users
    # A link to select any users from any page should be present
    # A link to remove all of them should be present
    #
    within ".header-bar--selection", text: "10 utilisateurs sélectionnés" do
      click_on "Sélectionner les 12 utilisateurs des 2 pages"
    end

    within ".header-bar--selection", text: "12 utilisateurs sélectionnés" do
      click_on "Tout supprimer"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer les 12 utilisateurs sélectionnés ?" do
      click_on "Continuer"
    end

    # The browser should stay on collectivity page
    # All users should have been removed
    #
    expect(page).to     have_current_path(organization_collectivity_path(pays_basque))
    expect(page).to     have_selector("h1", text: "CA du Pays Basque")
    expect(page).to     have_text("Aucun utilisateur assigné.")
    expect(page).not_to have_selector(:table_row, "Utilisateur" => "Christelle Droitier")
    expect(page).not_to have_selector(:table_row, "Utilisateur" => "Pierre Civil")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les utilisateurs sélectionnés ont été supprimés.")

    # The notification should include a button to cancel the last action
    #
    within "[role=alert]", text: "Les utilisateurs sélectionnés ont été supprimés." do
      click_on "Annuler"
    end

    # The browser should stay on collectivity page
    # All users should be back again
    #
    expect(page).to have_current_path(organization_collectivity_path(pays_basque))
    expect(page).to have_selector("h1", text: "CA du Pays Basque")
    expect(page).to have_text("12 utilisateurs | Page 1 sur 2")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Christelle Droitier")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Pierre Civil")

    # The selection message should not appears again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=alert]", text: "Les utilisateurs sélectionnés ont été supprimés.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression des utilisateurs sélectionnés a été annulée.")
  end
end
