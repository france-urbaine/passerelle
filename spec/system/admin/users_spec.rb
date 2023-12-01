# frozen_string_literal: true

require "system_helper"

RSpec.describe "Users in admin" do
  fixtures :regions, :departements, :epcis, :communes
  fixtures :publishers, :collectivities, :ddfips, :offices
  fixtures :users, :office_users

  let(:fiscalite_territoire) { publishers(:fiscalite_territoire) }
  let(:pays_basque)          { collectivities(:pays_basque) }
  let(:ddfip64)              { ddfips(:pyrenees_atlantiques) }
  let(:pelp_bayonne)         { offices(:pelp_bayonne) }
  let(:marc)                 { users(:marc) }
  let(:elise)                { users(:elise) }
  let(:christelle)           { users(:christelle) }
  let(:maxime)               { users(:maxime) }

  before { sign_in(users(:marc)) }

  it "visits index & user pages" do
    visit admin_users_path

    # A table of all users should be present
    #
    expect(page).to have_selector("h1", text: "Utilisateurs")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Marc Debomy")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Maxime Gauthier")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Christelle Droitier")

    click_on "Marc Debomy"

    # The browser should visit the user page
    #
    expect(page).to have_current_path(admin_user_path(marc))
    expect(page).to have_selector("h1", text: "Marc Debomy")

    go_back

    # The browser should redirect back to the index page
    #
    expect(page).to have_current_path(admin_users_path)
    expect(page).to have_selector("h1", text: "Utilisateurs")
  end

  it "visits user & audits pages" do
    visit admin_users_path
    click_on "Marc Debomy"

    # The browser should visit the user page
    #
    expect(page).to have_current_path(admin_user_path(marc))
    expect(page).to have_selector("a.button", text: "Voir toute l'activité")

    click_on "Voir toute l'activité"

    # The browser should visit the user audits page
    #
    expect(page).to have_current_path(admin_user_audits_path(marc))
    expect(page).to have_selector("pre.logs")
  end

  it "visits the links on a publisher user page & comes back" do
    visit admin_user_path(marc)

    # On the user page, we expect a link to the publisher
    #
    expect(page).to have_selector("h1", text: "Marc Debomy")
    expect(page).to have_link("Fiscalité & Territoire")

    click_on "Fiscalité & Territoire"

    # The browser should visit the publisher page
    #
    expect(page).to have_current_path(admin_publisher_path(fiscalite_territoire))
    expect(page).to have_selector("h1", text: "Fiscalité & Territoire")

    go_back

    # The browser should redirect back to the user page
    #
    expect(page).to have_current_path(admin_user_path(marc))
    expect(page).to have_selector("h1", text: "Marc Debomy")
  end

  it "visits the links on a collectivity user page & comes back" do
    visit admin_user_path(christelle)

    # On the user page, we expect a link to the collectivity
    #
    expect(page).to have_selector("h1", text: "Christelle Droitier")
    expect(page).to have_link("CA du Pays Basque")

    click_on "CA du Pays Basque"

    # The browser should visit the collectivity page
    #
    expect(page).to have_current_path(admin_collectivity_path(pays_basque))
    expect(page).to have_selector("h1", text: "CA du Pays Basque")

    go_back

    # The browser should redirect back to the user page
    #
    expect(page).to have_current_path(admin_user_path(christelle))
    expect(page).to have_selector("h1", text: "Christelle Droitier")
  end

  it "visits the links on a ddfip user page & comes back" do
    visit admin_user_path(maxime)

    # On the user page, we expect:
    # - a link to the DDFIP
    # - a link to each offices
    #
    expect(page).to have_selector("h1", text: "Maxime Gauthier")
    expect(page).to have_link("DDFIP des Pyrénées-Atlantiques")
    expect(page).to have_link("PELP de Bayonne")

    click_on "DDFIP des Pyrénées-Atlantiques"

    # The browser should visit the DDFIP page
    #
    expect(page).to have_current_path(admin_ddfip_path(ddfip64))
    expect(page).to have_selector("h1", text: "DDFIP des Pyrénées-Atlantiques")

    go_back

    # The browser should redirect back to the user page
    #
    expect(page).to have_current_path(admin_user_path(maxime))
    expect(page).to have_selector("h1", text: "Maxime Gauthier")

    click_on "PELP de Bayonne"

    # The browser should visit the office page
    #
    expect(page).to have_current_path(admin_office_path(pelp_bayonne))
    expect(page).to have_selector("h1", text: "PELP de Bayonne")

    go_back

    # The browser should redirect back to the user page
    #
    expect(page).to have_current_path(admin_user_path(maxime))
    expect(page).to have_selector("h1", text: "Maxime Gauthier")
  end

  it "invites an user from the index page" do
    visit admin_users_path

    # A button should be present to add a new user
    #
    click_on "Inviter un utilisateur"

    # A dialog box should appear with a form to fill
    #
    within "[role=dialog]", text: "Invitation d'un nouvel utilisateur" do |dialog|
      expect(dialog).to have_field("Organisation")
      expect(dialog).to have_field("Prénom")
      expect(dialog).to have_field("Nom")
      expect(dialog).to have_field("Adresse mail")
      expect(dialog).to have_unchecked_field("Administrateur de l'organisation")
      expect(dialog).to have_unchecked_field("Administrateur de la plateforme Passerelle")

      fill_in "Organisation", with: "Fiscalité"
      select_option "Fiscalité & Territoire", from: "Organisation"

      fill_in "Prénom",       with: "Elliot"
      fill_in "Nom",          with: "Alderson"
      fill_in "Adresse mail", with: "robot@fiscalite-territoire.fr"

      click_on "Enregistrer"
    end

    # The browser should stay on the index page
    # The new user should appear
    #
    expect(page).to have_current_path(admin_users_path)
    expect(page).to have_selector("h1", text: "Utilisateurs")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Elliot Alderson")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=log]", text: "Un nouvel utilisateur a été ajouté avec succés.")
  end

  it "invites an user from the index page to join some offices" do
    skip "Setting offices in admin is temporary removed"

    visit admin_users_path

    # A button should be present to add a new user
    #
    click_on "Inviter un utilisateur"

    # A dialog box should appear with a form to fill
    #
    within "[role=dialog]", text: "Invitation d'un nouvel utilisateur" do |dialog|
      expect(dialog).to have_field("Organisation")
      expect(dialog).to have_field("Prénom")
      expect(dialog).to have_field("Nom")
      expect(dialog).to have_field("Adresse mail")
      expect(dialog).to have_unchecked_field("Administrateur de l'organisation")
      expect(dialog).to have_unchecked_field("Administrateur de la plateforme Passerelle")

      fill_in "Organisation", with: "DDFIP"
      select_option "DDFIP des Pyrénées-Atlantiques", from: "Organisation"

      within ".form-block", text: "Guichets" do |block|
        expect(block).to have_unchecked_field("PELP de Bayonne")
        expect(block).to have_unchecked_field("PELH de Bayonne")
        expect(block).to have_unchecked_field("SIP de Bayonne")
      end

      fill_in "Prénom",       with: "Elliot"
      fill_in "Nom",          with: "Alderson"
      fill_in "Adresse mail", with: "robot@fiscalite-territoire.fr"

      check "PELP de Bayonne"
      check "PELH de Bayonne"

      click_on "Enregistrer"
    end

    # The browser should stay on the index page
    # The new user should appear
    #
    expect(page).to have_current_path(admin_users_path)
    expect(page).to have_selector("h1", text: "Utilisateurs")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Elliot Alderson")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=log]", text: "Un nouvel utilisateur a été ajouté avec succés.")

    # The new user should belong to checked offices
    #
    expect(User.last.offices)
      .to include(offices(:pelp_bayonne))
      .and include(offices(:pelh_bayonne))
      .and not_include(offices(:sip_bayonne))
  end

  it "updates an user from the index page" do
    visit admin_users_path

    # A button should be present to edit the user
    #
    within :table_row, { "Utilisateur" => "Marc Debomy" } do
      click_on "Modifier cet utilisateur"
    end

    # A dialog box should appear with a form
    # The form should be filled with user data
    #
    within "[role=dialog]", text: "Modification de l'utilisateur" do |dialog|
      expect(dialog).to have_field("Organisation", with: "Fiscalité & Territoire")
      expect(dialog).to have_field("Prénom",       with: "Marc")
      expect(dialog).to have_field("Nom",          with: "Debomy")
      expect(dialog).to have_field("Adresse mail", with: "mdebomy@fiscalite-territoire.fr")
      expect(dialog).to have_checked_field("Administrateur de l'organisation")
      expect(dialog).to have_checked_field("Administrateur de la plateforme Passerelle")

      fill_in "Prénom", with: "Marc-André"
      click_on "Enregistrer"
    end

    # The browser should stay on the index page
    # The user should have changed its name
    #
    expect(page).to have_current_path(admin_users_path)
    expect(page).to have_selector("h1", text: "Utilisateurs")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Marc-André Debomy")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=log]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "updates an user from the user page" do
    visit admin_user_path(marc)

    # A button should be present to edit the user
    #
    within ".header-bar", text: "Marc Debomy" do
      click_on "Modifier"
    end

    # A dialog box should appear with a form
    # The form should be filled with user data
    #
    within "[role=dialog]", text: "Modification de l'utilisateur" do |dialog|
      expect(dialog).to have_field("Organisation", with: "Fiscalité & Territoire")
      expect(dialog).to have_field("Prénom",       with: "Marc")
      expect(dialog).to have_field("Nom",          with: "Debomy")
      expect(dialog).to have_field("Adresse mail", with: "mdebomy@fiscalite-territoire.fr")
      expect(dialog).to have_checked_field("Administrateur de l'organisation")
      expect(dialog).to have_checked_field("Administrateur de la plateforme Passerelle")

      fill_in "Prénom", with: "Marc-André"
      click_on "Enregistrer"
    end

    # The browser should stay on the user page
    # The user should have changed its name
    #
    expect(page).to have_current_path(admin_user_path(marc))
    expect(page).to have_selector("h1", text: "Marc-André Debomy")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=log]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "resets a user from the user page" do
    visit admin_user_path(elise)

    expect(page).to have_selector("a.button", text: "Réinitialiser")

    click_on "Réinitialiser"

    # A dialog box should appear with a form
    # The form should be filled with user data
    #
    within "[role=dialog]", text: "Réinitialisation de l'utilisateur" do
      click_on "Continuer"
    end

    # The browser should stay on the user page
    # The user should have changed its name
    #
    expect(page).to have_current_path(admin_user_path(elise))

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=log]", text: "L'invitation a été envoyée.")
    expect(page).not_to have_selector("a.button", text: "Réinitialiser")
    expect(page).to     have_selector("a.button", text: "Renouveler l'invitation")
  end

  it "does not display reset button on user self page" do
    visit admin_user_path(marc)

    expect(page).not_to have_selector("a.button", text: "Réinitialiser")
  end

  it "discards an user from the index page & rollbacks" do
    visit admin_users_path

    expect(page).to have_text("8 utilisateurs | Page 1 sur 1")

    # A button should be present to remove the user
    #
    within :table_row, { "Utilisateur" => "Elise Lacroix" } do
      click_on "Supprimer cet utilisateur"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer cet utilisateur ?" do
      click_on "Continuer"
    end

    # The browser should stay on the index page
    # The user should not appears anymore
    #
    expect(page).to     have_current_path(admin_users_path)
    expect(page).to     have_selector("h1", text: "Utilisateurs")
    expect(page).to     have_text("7 utilisateurs | Page 1 sur 1")
    expect(page).not_to have_selector(:table_row, "Utilisateur" => "Elise Lacroix")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=log]", text: "L'utilisateur a été supprimé.")

    # The notification should include a button to cancel the last action
    #
    within "[role=log]", text: "L'utilisateur a été supprimé." do
      click_on "Annuler"
    end

    # The browser should stay on the index page
    # The user should be back again
    #
    expect(page).to have_current_path(admin_users_path)
    expect(page).to have_selector("h1", text: "Utilisateurs")
    expect(page).to have_text("8 utilisateurs | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Elise Lacroix")

    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector("[role=log]", text: "L'utilisateur a été supprimé.")
    expect(page).to     have_selector("[role=log]", text: "La suppression de l'utilisateur a été annulée.")
  end

  it "discards an user from the user page & rollbacks" do
    visit admin_user_path(elise)

    # A button should be present to edit the user
    #
    within ".header-bar", text: "Elise Lacroix" do
      click_on "Supprimer"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer cet utilisateur ?" do
      click_on "Continuer"
    end

    # The browser should redirect to the index page
    # The user should not appears anymore
    #
    expect(page).to     have_current_path(admin_users_path)
    expect(page).to     have_selector("h1", text: "Utilisateurs")
    expect(page).to     have_text("7 utilisateurs | Page 1 sur 1")
    expect(page).not_to have_selector(:table_row, "Utilisateur" => "Elise Lacroix")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=log]", text: "L'utilisateur a été supprimé.")

    # The notification should include a button to cancel the last action
    #
    within "[role=log]", text: "L'utilisateur a été supprimé." do
      click_on "Annuler"
    end

    # The browser should stay on the index page
    # The user should be back again
    #
    expect(page).to have_current_path(admin_users_path)
    expect(page).to have_selector("h1", text: "Utilisateurs")
    expect(page).to have_text("8 utilisateurs | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Elise Lacroix")

    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector("[role=log]", text: "L'utilisateur a été supprimé.")
    expect(page).to     have_selector("[role=log]", text: "La suppression de l'utilisateur a été annulée.")
  end

  it "discards himself and been disconnected" do
    visit admin_users_path

    expect(page).to have_text("8 utilisateurs | Page 1 sur 1")

    # A button should be present to remove the user
    #
    within :table_row, { "Utilisateur" => "Marc Debomy" } do
      click_on "Supprimer cet utilisateur"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer votre compte utilisateur ?" do
      click_on "Continuer"
    end

    # The browser should sign out and redirect to login form
    #
    expect(page).to have_current_path(new_user_session_path)
  end

  it "selects and discards one user from the index page & rollbacks" do
    visit admin_users_path

    expect(page).to have_text("8 utilisateurs | Page 1 sur 1")

    # Checkboxes should be present to select users
    #
    within :table_row, { "Utilisateur" => "Elise Lacroix" } do
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

    # The browser should stay on index page
    # The selected users should not appears anymore
    # Other users should remain
    #
    expect(page).to     have_current_path(admin_users_path)
    expect(page).to     have_selector("h1", text: "Utilisateurs")
    expect(page).to     have_text("7 utilisateurs | Page 1 sur 1")
    expect(page).not_to have_selector(:table_row, "Utilisateur" => "Elise Lacroix")
    expect(page).to     have_selector(:table_row, "Utilisateur" => "Maxime Gauthier")
    expect(page).to     have_selector(:table_row, "Utilisateur" => "Christelle Droitier")

    # The selection message should not appears anymore
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=log]", text: "Les utilisateurs sélectionnés ont été supprimés.")

    # The notification should include a button to cancel the last action
    #
    within "[role=log]", text: "Les utilisateurs sélectionnés ont été supprimés." do
      click_on "Annuler"
    end

    # The browser should stay on index page
    # The remove users should be back again
    #
    expect(page).to have_current_path(admin_users_path)
    expect(page).to have_selector("h1", text: "Utilisateurs")
    expect(page).to have_text("8 utilisateurs | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Elise Lacroix")

    # The selection message should not appears again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=log]", text: "Les utilisateurs sélectionnés ont été supprimés.")
    expect(page).to     have_selector("[role=log]", text: "La suppression des utilisateurs sélectionnés a été annulée.")
  end

  it "selects and discards all users from the current page on index page & rollbacks" do
    # Create a bunch of users to have several pages
    # Create discarded users to verify they are not rollbacked
    #
    create_list(:user, 10, :using_existing_organizations)
    create_list(:user, 5, :using_existing_organizations, :discarded)

    visit admin_users_path

    expect(page).to have_text("18 utilisateurs | Page 1 sur 1")

    # Paginate users by 10
    # More than one page should exist
    #
    click_on "Options d'affichage"
    click_on "Afficher 50 lignes par page"
    click_on "Afficher 10 lignes"

    expect(page).to have_text("18 utilisateurs | Page 1 sur 2")

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

    # The browser should stay on index page
    # The selected users should have been removed
    # The current user should not have been removed
    #
    expect(page).to     have_current_path(admin_users_path)
    expect(page).to     have_selector("h1", text: "Utilisateurs")
    expect(page).to     have_text("9 utilisateurs | Page 1 sur 1")
    expect(page).to     have_selector(:table_row, "Utilisateur" => "Marc Debomy")
    expect(page).not_to have_selector(:table_row, "Utilisateur" => "Maxime Gauthier")
    expect(page).not_to have_selector(:table_row, "Utilisateur" => "Christelle Droitier")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=log]", text: "Les utilisateurs sélectionnés ont été supprimés.")

    # The notification should include a button to cancel the last action
    #
    within "[role=log]", text: "Les utilisateurs sélectionnés ont été supprimés." do
      click_on "Annuler"
    end

    # The browser should stay on index page
    # All users should be back again
    #
    expect(page).to have_current_path(admin_users_path)
    expect(page).to have_selector("h1", text: "Utilisateurs")
    expect(page).to have_text("18 utilisateurs | Page 1 sur 2")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Marc Debomy")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Maxime Gauthier")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Christelle Droitier")

    # The selection message should not appears again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=log]", text: "Les utilisateurs sélectionnés ont été supprimés.")
    expect(page).to     have_selector("[role=log]", text: "La suppression des utilisateurs sélectionnés a été annulée.")
  end

  it "selects and discards all users through several pages on index page & rollbacks" do
    # Create a bunch of users to have several pages
    # TODO: Create discarded users to verify they are not rollbacked
    #
    create_list(:user, 10, :using_existing_organizations)

    visit admin_users_path

    expect(page).to have_text("18 utilisateurs | Page 1 sur 1")

    # Paginate users by 10
    # More than one page should exist
    #
    click_on "Options d'affichage"
    click_on "Afficher 50 lignes par page"
    click_on "Afficher 10 lignes"

    expect(page).to have_text("18 utilisateurs | Page 1 sur 2")

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
      click_on "Sélectionner les 18 utilisateurs des 2 pages"
    end

    within ".header-bar--selection", text: "18 utilisateurs sélectionnés" do
      click_on "Tout supprimer"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer les 18 utilisateurs sélectionnés ?" do
      click_on "Continuer"
    end

    # The browser should stay on index page
    # The current user is the only one remaining user
    #
    expect(page).to     have_current_path(admin_users_path)
    expect(page).to     have_selector("h1", text: "Utilisateurs")
    expect(page).to     have_text("1 utilisateur | Page 1 sur 1")
    expect(page).to     have_selector(:table_row, "Utilisateur" => "Marc Debomy")
    expect(page).not_to have_selector(:table_row, "Utilisateur" => "Maxime Gauthier")
    expect(page).not_to have_selector(:table_row, "Utilisateur" => "Christelle Droitier")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=log]", text: "Les utilisateurs sélectionnés ont été supprimés.")

    # The notification should include a button to cancel the last action
    #
    within "[role=log]", text: "Les utilisateurs sélectionnés ont été supprimés." do
      click_on "Annuler"
    end

    # The browser should stay on index page
    # All users should be back again
    #
    expect(page).to have_current_path(admin_users_path)
    expect(page).to have_selector("h1", text: "Utilisateurs")
    expect(page).to have_text("18 utilisateurs | Page 1 sur 2")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Marc Debomy")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Maxime Gauthier")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Christelle Droitier")

    # The selection message should not appears again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=log]", text: "Les utilisateurs sélectionnés ont été supprimés.")
    expect(page).to     have_selector("[role=log]", text: "La suppression des utilisateurs sélectionnés a été annulée.")
  end
end
