# frozen_string_literal: true

require "system_helper"

RSpec.describe "Collectivity users in admin" do
  fixtures :publishers, :collectivities, :users

  let(:pays_basque) { collectivities(:pays_basque) }
  let(:christelle)  { users(:christelle) }

  before { sign_in(users(:marc)) }

  it "visits an user page from the collectivity page" do
    visit admin_collectivity_path(pays_basque)

    # A table of all users should be present
    #
    expect(page).to have_selector("h1", text: "CA du Pays Basque")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Christelle Droitier")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Pierre Civil")

    click_on "Christelle Droitier"

    # The browser should visit the user page
    #
    expect(page).to have_current_path(admin_user_path(christelle))
    expect(page).to have_selector("h1", text: "Christelle Droitier")

    go_back

    # The browser should redirect back to the collectivity page
    #
    expect(page).to have_current_path(admin_collectivity_path(pays_basque))
    expect(page).to have_selector("h1", text: "CA du Pays Basque")
  end

  it "paginate users on the collectivity page" do
    # Create enough users to have several pages
    #
    create_list(:user, 10, organization: pays_basque)

    visit admin_collectivity_path(pays_basque)

    expect(page).to     have_text("12 utilisateurs | Page 1 sur 2")
    expect(page).not_to have_button("Options d'affichage")
  end

  it "invites an user from the collectivity page" do
    visit admin_collectivity_path(pays_basque)

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
      expect(dialog).to have_unchecked_field("Administrateur de la plateforme FiscaHub")

      fill_in "Prénom",       with: "Elliot"
      fill_in "Nom",          with: "Alderson"
      fill_in "Adresse mail", with: "robot@fiscalite-territoire.fr"

      click_on "Enregistrer"
    end

    # The browser should stay on the collectivity page
    # The new user should appear
    #
    expect(page).to have_current_path(admin_collectivity_path(pays_basque))
    expect(page).to have_selector("h1", text: "CA du Pays Basque")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Elliot Alderson")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Un nouvel utilisateur a été ajouté avec succés.")
  end

  it "updates an user from the collectivity page" do
    visit admin_collectivity_path(pays_basque)

    # A table of users should be present
    # with a button to edit them
    #
    within :table_row, { "Utilisateur" => "Christelle Droitier" } do
      click_on "Modifier cet utilisateur"
    end

    # A dialog box should appear with a form
    # The form should be filled with user data
    #
    within "[role=dialog]", text: "Modification de l'utilisateur" do |dialog|
      expect(dialog).to have_field("Organisation", with: "CA du Pays Basque")
      expect(dialog).to have_field("Prénom",       with: "Christelle")
      expect(dialog).to have_field("Nom",          with: "Droitier")
      expect(dialog).to have_field("Adresse mail", with: "christelle.droitier@paysbasque.fr")
      expect(dialog).to have_checked_field("Administrateur de l'organisation")
      expect(dialog).to have_unchecked_field("Administrateur de la plateforme FiscaHub")

      fill_in "Prénom", with: "Marie-Christelle"
      click_on "Enregistrer"
    end

    # The browser should stay on the collectivity page
    # The user's name should have been updated
    #
    expect(page).to have_current_path(admin_collectivity_path(pays_basque))
    expect(page).to have_selector("h1", text: "CA du Pays Basque")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Marie-Christelle Droitier")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "discards an user from the collectivity page & rollbacks" do
    visit admin_collectivity_path(pays_basque)

    expect(page).to have_text("2 utilisateurs | Page 1 sur 1")

    # A table of users should be present
    # with a button to remove them
    #
    within :table_row, { "Utilisateur" => "Christelle Droitier" } do
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
    expect(page).to     have_current_path(admin_collectivity_path(pays_basque))
    expect(page).to     have_selector("h1", text: "CA du Pays Basque")
    expect(page).to     have_text("1 utilisateur | Page 1 sur 1")
    expect(page).not_to have_selector(:table_row, "Utilisateur" => "Christelle Droitier")

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
    # The user should not appears anymore
    # The user should be back again
    #
    expect(page).to have_current_path(admin_collectivity_path(pays_basque))
    expect(page).to have_selector("h1", text: "CA du Pays Basque")
    expect(page).to have_text("2 utilisateurs | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Christelle Droitier")

    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector("[role=alert]", text: "L'utilisateur a été supprimé.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression de l'utilisateur a été annulée.")
  end

  it "selects and discards one user from the collectivity page & rollbacks" do
    visit admin_collectivity_path(pays_basque)

    expect(page).to have_text("2 utilisateurs | Page 1 sur 1")

    # Some checkboxes should be present to select users
    #
    within :table_row, { "Utilisateur" => "Christelle Droitier" } do
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

    # The browser should stay on the publisher page
    # The selected users should not appears anymore
    # Other users should remain
    #
    expect(page).to     have_current_path(admin_collectivity_path(pays_basque))
    expect(page).to     have_selector("h1", text: "CA du Pays Basque")
    expect(page).to     have_text("1 utilisateur | Page 1 sur 1")
    expect(page).not_to have_selector(:table_row, "Utilisateur" => "Christelle Droitier")
    expect(page).to     have_selector(:table_row, "Utilisateur" => "Pierre Civil")

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

    # The browser should stay on the collectivity page
    # The removed users should be back again
    #
    expect(page).to have_current_path(admin_collectivity_path(pays_basque))
    expect(page).to have_selector("h1", text: "CA du Pays Basque")
    expect(page).to have_text("2 utilisateurs | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Christelle Droitier")

    # The selection message should not appears again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=alert]", text: "Les utilisateurs sélectionnés ont été supprimés.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression des utilisateurs sélectionnés a été annulée.")
  end

  it "selects and discards all users from the current page on the collectivity page & rollbacks" do
    # Create a bunch of users to have several pages
    # Also create discarded users on other organizations to ensure there are not rollbacked
    #
    create_list(:user, 10, organization: pays_basque)
    create_list(:user, 5, :discarded)

    visit admin_collectivity_path(pays_basque)

    expect(page).to have_text("12 utilisateurs | Page 1 sur 2")

    # Checkboxes should be present to select all users
    #
    within "#datatable-users" do
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

    # The browser should stay on the collectivity page
    # No users should appear anymore
    #
    expect(page).to     have_current_path(admin_collectivity_path(pays_basque))
    expect(page).to     have_selector("h1", text: "CA du Pays Basque")
    expect(page).to     have_text("2 utilisateurs | Page 1 sur 1")
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

    # The browser should stay on the collectivity page
    # The removed users should be back again
    #
    expect(page).to have_current_path(admin_collectivity_path(pays_basque))
    expect(page).to have_selector("h1", text: "CA du Pays Basque")
    expect(page).to have_text("12 utilisateurs | Page 1 sur 2")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Christelle Droitier")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Pierre Civil")

    expect(User.discarded.count).to eq(5)

    # The selection message should not appears again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=alert]", text: "Les utilisateurs sélectionnés ont été supprimés.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression des utilisateurs sélectionnés a été annulée.")
  end

  it "selects and discards all users through several pages on the collectivity page & rollbacks" do
    # Create a bunch of users to have several pages
    # Also create discarded users on other organizations to ensure there are not rollbacked
    #
    create_list(:user, 10, organization: pays_basque)
    create_list(:user, 5, :discarded)

    visit admin_collectivity_path(pays_basque)

    expect(page).to have_text("12 utilisateurs | Page 1 sur 2")

    # Checkboxes should be present to select all users
    #
    within "#datatable-users" do
      check nil, match: :first
    end

    # A message should diplay the number of selected users
    # with a button to remove them
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

    # The browser should stay on the collectivity page
    # No users should appear anymore
    # Other users from other organizations should remain
    #
    expect(page).to have_current_path(admin_collectivity_path(pays_basque))
    expect(page).to have_selector("h1", text: "CA du Pays Basque")
    expect(page).to have_text("Aucun utilisateur assigné.")

    expect(User.discarded.count).to eq(17)

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

    # The browser should stay on the collectivity page
    # The removed users should be back again
    #
    expect(page).to have_current_path(admin_collectivity_path(pays_basque))
    expect(page).to have_selector("h1", text: "CA du Pays Basque")
    expect(page).to have_text("12 utilisateurs | Page 1 sur 2")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Christelle Droitier")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Pierre Civil")

    expect(User.discarded.count).to eq(5)

    # The selection message should not appears again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=alert]", text: "Les utilisateurs sélectionnés ont été supprimés.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression des utilisateurs sélectionnés a été annulée.")
  end
end
