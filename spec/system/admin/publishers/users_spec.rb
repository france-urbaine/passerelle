# frozen_string_literal: true

require "system_helper"

RSpec.describe "Publisher users in admin" do
  fixtures :regions, :departements, :epcis, :communes
  fixtures :publishers, :collectivities, :ddfips, :offices
  fixtures :users

  let(:solutions_territoire) { publishers(:solutions_territoire) }
  let(:marc)                 { users(:marc) }

  before { sign_in(users(:marc)) }

  it "visits an user page from the publisher page" do
    visit admin_publisher_path(solutions_territoire)

    # A table of users should be present
    #
    expect(page).to have_selector("h1", text: "Solutions & Territoire")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Marc Debomy")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Elise Lacroix")

    click_on "Marc Debomy"

    # The browser should visit the user page
    #
    expect(page).to have_current_path(admin_user_path(marc))
    expect(page).to have_selector("h1", text: "Marc Debomy")

    go_back

    # The browser should have redirect back to the publisher page
    #
    expect(page).to have_current_path(admin_publisher_path(solutions_territoire))
    expect(page).to have_selector("h1", text: "Solutions & Territoire")
  end

  it "paginate users on the publisher page" do
    # Create enough users to have several pages
    #
    create_list(:user, 10, organization: solutions_territoire)

    visit admin_publisher_path(solutions_territoire)

    expect(page).to have_text("13 utilisateurs | Page 1 sur 2")
    expect(page).to have_no_button("Options d'affichage")
  end

  it "invites an user from the publisher page" do
    visit admin_publisher_path(solutions_territoire)

    # A button should be present to add a new user
    #
    click_on "Inviter un utilisateur"

    # A dialog box should appear with a form to fill
    #
    within "[role=dialog]", text: "Invitation d'un nouvel utilisateur" do |dialog|
      expect(dialog).to have_no_field("Organisation")

      expect(dialog).to have_field("Prénom")
      expect(dialog).to have_field("Nom")
      expect(dialog).to have_field("Adresse mail")
      expect(dialog).to have_unchecked_field("Administrateur de l'organisation")
      expect(dialog).to have_unchecked_field("Administrateur de la plateforme Passerelle")

      fill_in "Prénom",       with: "Elliot"
      fill_in "Nom",          with: "Alderson"
      fill_in "Adresse mail", with: "robot@solutions-territoire.fr"

      click_on "Enregistrer"
    end

    # The browser should stay on the publisher page
    # The new user should appear
    #
    expect(page).to have_current_path(admin_publisher_path(solutions_territoire))
    expect(page).to have_selector("h1", text: "Solutions & Territoire")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Elliot Alderson")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to have_no_selector("[role=dialog]")
    expect(page).to have_selector("[role=log]", text: "Un nouvel utilisateur a été ajouté avec succés.")
  end

  it "updates an user from the publisher page" do
    visit admin_publisher_path(solutions_territoire)

    # A table of users should be present
    # with a button to edit them
    #
    within :table_row, { "Utilisateur" => "Marc Debomy" } do
      click_on "Modifier cet utilisateur"
    end

    # A dialog box should appear with a form
    # The form should be filled with user data
    #
    within "[role=dialog]", text: "Modification de l'utilisateur" do |dialog|
      expect(dialog).to have_field("Organisation", with: "Solutions & Territoire")
      expect(dialog).to have_field("Prénom",       with: "Marc")
      expect(dialog).to have_field("Nom",          with: "Debomy")
      expect(dialog).to have_field("Adresse mail", with: "mdebomy@solutions-territoire.fr")
      expect(dialog).to have_checked_field("Administrateur de l'organisation")
      expect(dialog).to have_checked_field("Administrateur de la plateforme Passerelle")

      fill_in "Prénom", with: "Marc-André"
      click_on "Enregistrer"
    end

    # The browser should stay on the publisher page
    # The user's name should have been updated
    #
    expect(page).to have_current_path(admin_publisher_path(solutions_territoire))
    expect(page).to have_selector("h1", text: "Solutions & Territoire")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Marc-André Debomy")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to have_no_selector("[role=dialog]")
    expect(page).to have_selector("[role=log]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "discards an user from the publisher page & rollbacks" do
    visit admin_publisher_path(solutions_territoire)

    expect(page).to have_text("3 utilisateurs | Page 1 sur 1")

    # A table of users should be present
    # with a button to remove them
    #
    within :table_row, { "Utilisateur" => "Elise Lacroix" } do
      click_on "Supprimer cet utilisateur"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer cet utilisateur ?" do
      click_on "Continuer"
    end

    # The browser should stay on the publisher page
    # The user should not appear anymore
    #
    expect(page).to have_current_path(admin_publisher_path(solutions_territoire))
    expect(page).to have_selector("h1", text: "Solutions & Territoire")
    expect(page).to have_text("2 utilisateurs | Page 1 sur 1")
    expect(page).to have_no_selector(:table_row, "Utilisateur" => "Elise Lacroix")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to have_no_selector("[role=dialog]")
    expect(page).to have_selector("[role=log]", text: "L'utilisateur a été supprimé.")

    # The notification should include a button to cancel the last action
    #
    within "[role=log]", text: "L'utilisateur a été supprimé." do
      click_on "Annuler"
    end

    # The browser should stay on the publisher page
    # The user should not appear anymore
    # The user should be back again
    #
    expect(page).to have_current_path(admin_publisher_path(solutions_territoire))
    expect(page).to have_selector("h1", text: "Solutions & Territoire")
    expect(page).to have_text("3 utilisateurs | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Elise Lacroix")

    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).to have_no_selector("[role=log]", text: "L'utilisateur a été supprimé.")
    expect(page).to have_selector("[role=log]", text: "La suppression de l'utilisateur a été annulée.")
  end

  it "selects and discards one user from the publisher page & rollbacks" do
    visit admin_publisher_path(solutions_territoire)

    expect(page).to have_text("3 utilisateurs | Page 1 sur 1")

    # Checkboxes should be present to select users
    #
    within :table_row, { "Utilisateur" => "Elise Lacroix" } do
      check
    end

    # A message should diplay the number of selected users
    # with a button to remove them
    #
    within ".datatable__selection", text: "1 utilisateur sélectionné" do
      click_on "Tout supprimer"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer l'utilisateur sélectionné ?" do
      click_on "Continuer"
    end

    # The browser should stay on the publisher page
    # The selected users should not appear anymore
    # Other users should remain
    #
    expect(page).to have_current_path(admin_publisher_path(solutions_territoire))
    expect(page).to have_selector("h1", text: "Solutions & Territoire")
    expect(page).to have_text("2 utilisateurs | Page 1 sur 1")
    expect(page).to have_no_selector(:table_row, "Utilisateur" => "Elise Lacroix")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Marc Debomy")

    # The selection message should not appear anymore
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to have_no_selector(".datatable__selection")
    expect(page).to have_no_selector("[role=dialog]")
    expect(page).to have_selector("[role=log]", text: "Les utilisateurs sélectionnés ont été supprimés.")

    # The notification should include a button to cancel the last action
    #
    within "[role=log]", text: "Les utilisateurs sélectionnés ont été supprimés." do
      click_on "Annuler"
    end

    # The browser should stay on the publisher page
    # The removed users should be back again
    #
    expect(page).to have_current_path(admin_publisher_path(solutions_territoire))
    expect(page).to have_selector("h1", text: "Solutions & Territoire")
    expect(page).to have_text("3 utilisateurs | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Elise Lacroix")

    # The selection message should not appear again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).to have_no_selector(".datatable__selection")
    expect(page).to have_no_selector("[role=log]", text: "Les utilisateurs sélectionnés ont été supprimés.")
    expect(page).to have_selector("[role=log]", text: "La suppression des utilisateurs sélectionnés a été annulée.")
  end

  it "selects and discards all users from the current page on the publisher page & rollbacks" do
    # Create a bunch of users to have several pages
    # Also create discarded users on other organizations to ensure there are not rollbacked
    #
    create_list(:user, 10, organization: solutions_territoire)
    create_list(:user, 5, :discarded)

    visit admin_publisher_path(solutions_territoire)

    expect(page).to have_text("13 utilisateurs | Page 1 sur 2")

    # Checkboxes should be present to select all users
    #
    within "#datatable-users" do
      check nil, match: :first
    end

    # A message should diplay the number of selected users
    # with a button to remove them
    #
    within ".datatable__selection", text: "10 utilisateurs sélectionnés" do
      click_on "Tout supprimer"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer les 10 utilisateurs sélectionnés ?" do
      click_on "Continuer"
    end

    # The browser should stay on the publisher page
    # The selected users should have been removed
    # The current user should not have been removed
    #
    expect(page).to have_current_path(admin_publisher_path(solutions_territoire))
    expect(page).to have_selector("h1", text: "Solutions & Territoire")
    expect(page).to have_text("4 utilisateurs | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Marc Debomy")
    expect(page).to have_no_selector(:table_row, "Utilisateur" => "Elise Lacroix")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to have_no_selector(".datatable__selection")
    expect(page).to have_no_selector("[role=dialog]")
    expect(page).to have_selector("[role=log]", text: "Les utilisateurs sélectionnés ont été supprimés.")

    # The notification should include a button to cancel the last action
    #
    within "[role=log]", text: "Les utilisateurs sélectionnés ont été supprimés." do
      click_on "Annuler"
    end

    # The browser should stay on the publisher page
    # The removed users should be back again
    #
    expect(page).to have_current_path(admin_publisher_path(solutions_territoire))
    expect(page).to have_selector("h1", text: "Solutions & Territoire")
    expect(page).to have_text("13 utilisateurs | Page 1 sur 2")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Elise Lacroix")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Elise Lacroix")

    expect(User.discarded.count).to eq(5)

    # The selection message should not appear again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).to have_no_selector(".datatable__selection")
    expect(page).to have_no_selector("[role=log]", text: "Les utilisateurs sélectionnés ont été supprimés.")
    expect(page).to have_selector("[role=log]", text: "La suppression des utilisateurs sélectionnés a été annulée.")
  end

  it "selects and discards all users through several pages on the publisher page & rollbacks" do
    # Create a bunch of users to have several pages
    # Also create discarded users on other organizations to ensure there are not rollbacked
    #
    create_list(:user, 10, organization: solutions_territoire)
    create_list(:user, 5, :discarded)

    visit admin_publisher_path(solutions_territoire)

    expect(page).to have_text("13 utilisateurs | Page 1 sur 2")

    # Checkboxes should be present to select all users
    #
    within "#datatable-users" do
      check nil, match: :first
    end

    # A message should diplay the number of selected users
    # with a button to remove them
    #
    within ".datatable__selection", text: "10 utilisateurs sélectionnés" do
      click_on "Sélectionner les 13 utilisateurs des 2 pages"
    end

    within ".datatable__selection", text: "13 utilisateurs sélectionnés" do
      click_on "Tout supprimer"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer les 13 utilisateurs sélectionnés ?" do
      click_on "Continuer"
    end

    # The browser should stay on the publisher page
    # The current user is the only one remaining user
    # Other users from other organizations should remain
    #
    expect(page).to have_current_path(admin_publisher_path(solutions_territoire))
    expect(page).to have_selector("h1", text: "Solutions & Territoire")
    expect(page).to have_text("1 utilisateur | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Marc Debomy")
    expect(page).to have_no_selector(:table_row, "Utilisateur" => "Elise Lacroix")

    expect(User.discarded.count).to eq(17)

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to have_no_selector(".datatable__selection")
    expect(page).to have_no_selector("[role=dialog]")
    expect(page).to have_selector("[role=log]", text: "Les utilisateurs sélectionnés ont été supprimés.")

    # The notification should include a button to cancel the last action
    #
    within "[role=log]", text: "Les utilisateurs sélectionnés ont été supprimés." do
      click_on "Annuler"
    end

    # The browser should stay on the publisher page
    # The removed users should be back again
    #
    expect(page).to have_current_path(admin_publisher_path(solutions_territoire))
    expect(page).to have_selector("h1", text: "Solutions & Territoire")
    expect(page).to have_text("13 utilisateurs | Page 1 sur 2")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Marc Debomy")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Elise Lacroix")

    expect(User.discarded.count).to eq(5)

    # The selection message should not appear again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).to have_no_selector(".datatable__selection")
    expect(page).to have_no_selector("[role=log]", text: "Les utilisateurs sélectionnés ont été supprimés.")
    expect(page).to have_selector("[role=log]", text: "La suppression des utilisateurs sélectionnés a été annulée.")
  end
end
