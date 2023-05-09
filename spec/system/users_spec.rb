# frozen_string_literal: true

require "system_helper"

RSpec.describe "Managing users" do
  fixtures :regions, :departements, :epcis, :communes
  fixtures :publishers, :collectivities, :ddfips, :offices
  fixtures :users, :office_users

  let(:fiscalite_territoire) { publishers(:fiscalite_territoire) }
  let(:pays_basque)          { collectivities(:pays_basque) }
  let(:ddfip64)              { ddfips(:pyrenees_atlantiques) }
  let(:pelp_bayonne)         { offices(:pelp_bayonne) }
  let(:marc)                 { users(:marc) }
  let(:christelle)           { users(:christelle) }
  let(:maxime)               { users(:maxime) }

  it "visits index & show pages" do
    visit users_path

    # A table of all users should be present
    #
    expect(page).to have_selector("h1", text: "Utilisateurs")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Marc Debomy")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Maxime Gauthier")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Christelle Droitier")

    click_on "Marc Debomy"

    # The browser should redirect to the user page
    #
    expect(page).to have_current_path(user_path(marc))
    expect(page).to have_selector("h1", text: "Marc Debomy")

    go_back

    # The browser should redirect back to index page
    #
    expect(page).to have_current_path(users_path)
    expect(page).to have_selector("h1", text: "Utilisateurs")
  end

  it "visits the links of a publisher user page and then comes back" do
    visit user_path(marc)

    # A link to the publisher should be present
    #
    expect(page).to have_selector("h1", text: "Marc Debomy")
    expect(page).to have_link("Fiscalité & Territoire")

    click_on "Fiscalité & Territoire"

    # The browser should redirect to the publisher page
    #
    expect(page).to have_current_path(publisher_path(fiscalite_territoire))
    expect(page).to have_selector("h1", text: "Fiscalité & Territoire")

    go_back

    # The browser should redirect back to user page
    #
    expect(page).to have_current_path(user_path(marc))
    expect(page).to have_selector("h1", text: "Marc Debomy")
  end

  it "visits the links of a collectivity user page and then comes back" do
    visit user_path(christelle)

    # A link to the collectivity should be present
    #
    expect(page).to have_selector("h1", text: "Christelle Droitier")
    expect(page).to have_link("CA du Pays Basque")

    click_on "CA du Pays Basque"

    # The browser should redirect to the publisher page
    #
    expect(page).to have_current_path(collectivity_path(pays_basque))
    expect(page).to have_selector("h1", text: "CA du Pays Basque")

    go_back

    # The browser should redirect back to user page
    #
    expect(page).to have_current_path(user_path(christelle))
    expect(page).to have_selector("h1", text: "Christelle Droitier")
  end

  it "visits the links of a ddfip user page and then comes back" do
    visit user_path(maxime)

    # A link to the DDFIP and the offices should be present
    #
    expect(page).to have_selector("h1", text: "Maxime Gauthier")
    expect(page).to have_link("DDFIP des Pyrénées-Atlantiques")
    expect(page).to have_link("PELP de Bayonne")

    click_on "DDFIP des Pyrénées-Atlantiques"

    # The browser should redirect to the publisher page
    #
    expect(page).to have_current_path(ddfip_path(ddfip64))
    expect(page).to have_selector("h1", text: "DDFIP des Pyrénées-Atlantiques")

    go_back

    # The browser should redirect back to user page
    #
    expect(page).to have_current_path(user_path(maxime))
    expect(page).to have_selector("h1", text: "Maxime Gauthier")

    click_on "PELP de Bayonne"

    # The browser should redirect to the publisher page
    #
    expect(page).to have_current_path(office_path(pelp_bayonne))
    expect(page).to have_selector("h1", text: "PELP de Bayonne")

    go_back

    # The browser should redirect back to user page
    #
    expect(page).to have_current_path(user_path(maxime))
    expect(page).to have_selector("h1", text: "Maxime Gauthier")
  end

  it "invites an user from the index page" do
    visit users_path

    # A button should be present to add a new user
    #
    click_on "Inviter un utilisateur"

    # A dialog box should appears with a form to fill
    #
    within "[role=dialog]", text: "Invitation d'un nouvel utilisateur" do |dialog|
      expect(dialog).to have_field("Organisation")
      expect(dialog).to have_field("Prénom")
      expect(dialog).to have_field("Nom")
      expect(dialog).to have_field("Adresse mail")
      expect(dialog).to have_unchecked_field("Administrateur de l'organisation")
      expect(dialog).to have_unchecked_field("Administrateur de la plateforme FiscaHub")

      fill_in "Organisation", with: "Fiscalité"
      select_option "Fiscalité & Territoire", from: "Organisation"

      fill_in "Prénom",       with: "Elliot"
      fill_in "Nom",          with: "Alderson"
      fill_in "Adresse mail", with: "robot@fiscalite-territoire.fr"

      click_on "Enregistrer"
    end

    # The browser should stay on index page
    # The new user should appears
    #
    expect(page).to have_current_path(users_path)
    expect(page).to have_selector("h1", text: "Utilisateurs")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Elliot Alderson")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Un nouvel utilisateur a été ajouté avec succés.")
  end

  it "invites an user from the index page to join some offices" do
    visit users_path

    # A button should be present to add a new user
    #
    click_on "Inviter un utilisateur"

    # A dialog box should appears with a form to fill
    #
    within "[role=dialog]", text: "Invitation d'un nouvel utilisateur" do |dialog|
      expect(dialog).to have_field("Organisation")
      expect(dialog).to have_field("Prénom")
      expect(dialog).to have_field("Nom")
      expect(dialog).to have_field("Adresse mail")
      expect(dialog).to have_unchecked_field("Administrateur de l'organisation")
      expect(dialog).to have_unchecked_field("Administrateur de la plateforme FiscaHub")

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

    # The browser should stay on index page
    # The new user should appears
    #
    expect(page).to have_current_path(users_path)
    expect(page).to have_selector("h1", text: "Utilisateurs")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Elliot Alderson")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Un nouvel utilisateur a été ajouté avec succés.")

    # The new user should belong to checked offices
    #
    expect(User.last.offices)
      .to include(offices(:pelp_bayonne))
      .and include(offices(:pelh_bayonne))
      .and not_include(offices(:sip_bayonne))
  end

  it "updates an user from the index page" do
    visit users_path

    # A button should be present to edit the user
    #
    within :table_row, { "Utilisateur" => "Marc Debomy" } do
      click_on "Modifier cet utilisateur"
    end

    # A dialog box should appears with a form
    # The form should be filled with user data
    #
    within "[role=dialog]", text: "Modification de l'utilisateur" do |dialog|
      expect(dialog).to have_field("Organisation", with: "Fiscalité & Territoire")
      expect(dialog).to have_field("Prénom",       with: "Marc")
      expect(dialog).to have_field("Nom",          with: "Debomy")
      expect(dialog).to have_field("Adresse mail", with: "mdebomy@fiscalite-territoire.fr")
      expect(dialog).to have_unchecked_field("Administrateur de l'organisation")
      expect(dialog).to have_checked_field("Administrateur de la plateforme FiscaHub")

      fill_in "Prénom", with: "Marc-André"
      click_on "Enregistrer"
    end

    # The browser should stay on index page
    # The user should have changed its name
    #
    expect(page).to have_current_path(users_path)
    expect(page).to have_selector("h1", text: "Utilisateurs")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Marc-André Debomy")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "updates an user from the user page" do
    visit user_path(marc)

    # A button should be present to edit the user
    #
    within ".header-bar", text: "Marc Debomy" do
      click_on "Modifier"
    end

    # A dialog box should appears with a form
    # The form should be filled with user data
    #
    within "[role=dialog]", text: "Modification de l'utilisateur" do |dialog|
      expect(dialog).to have_field("Organisation", with: "Fiscalité & Territoire")
      expect(dialog).to have_field("Prénom",       with: "Marc")
      expect(dialog).to have_field("Nom",          with: "Debomy")
      expect(dialog).to have_field("Adresse mail", with: "mdebomy@fiscalite-territoire.fr")
      expect(dialog).to have_unchecked_field("Administrateur de l'organisation")
      expect(dialog).to have_checked_field("Administrateur de la plateforme FiscaHub")

      fill_in "Prénom", with: "Marc-André"
      click_on "Enregistrer"
    end

    # The browser should stay on index page
    # The user should have changed its name
    #
    expect(page).to have_current_path(user_path(marc))
    expect(page).to have_selector("h1", text: "Marc-André Debomy")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "discards an user from the index page and then rollbacks" do
    visit users_path

    expect(page).to have_text("6 utilisateurs | Page 1 sur 1")

    # A button should be present to remove th user
    #
    within :table_row, { "Utilisateur" => "Marc Debomy" } do
      click_on "Supprimer cet utilisateur"
    end

    # A confirmation dialog should appears
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer cet utilisateur ?" do
      click_on "Continuer"
    end

    # The browser should stay on index page
    # The user should not appears anymore
    #
    expect(page).to     have_current_path(users_path)
    expect(page).to     have_selector("h1", text: "Utilisateurs")
    expect(page).to     have_text("5 utilisateurs | Page 1 sur 1")
    expect(page).not_to have_selector(:table_row, "Utilisateur" => "Marc Debomy")

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

    # The browser should stay on index page
    # The user should be back again
    #
    expect(page).to have_current_path(users_path)
    expect(page).to have_selector("h1", text: "Utilisateurs")
    expect(page).to have_text("6 utilisateurs | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Marc Debomy")

    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector("[role=alert]", text: "L'utilisateur a été supprimé.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression de l'utilisateur a été annulée.")
  end

  it "discards an user from the user page and then rollbacks" do
    visit user_path(marc)

    # A button should be present to edit the user
    #
    within ".header-bar", text: "Marc Debomy" do
      click_on "Supprimer"
    end

    # A confirmation dialog should appears
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer cet utilisateur ?" do
      click_on "Continuer"
    end

    # The browser should redirect to the index page
    # The user should not appears anymore
    #
    expect(page).to     have_current_path(users_path)
    expect(page).to     have_selector("h1", text: "Utilisateurs")
    expect(page).to     have_text("5 utilisateurs | Page 1 sur 1")
    expect(page).not_to have_selector(:table_row, "Utilisateur" => "Marc Debomy")

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

    # The browser should stay on index page
    # The user should be back again
    #
    expect(page).to have_current_path(users_path)
    expect(page).to have_selector("h1", text: "Utilisateurs")
    expect(page).to have_text("6 utilisateurs | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Marc Debomy")

    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector("[role=alert]", text: "L'utilisateur a été supprimé.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression de l'utilisateur a été annulée.")
  end

  it "selects and discards one user from the index page and then rollbacks" do
    visit users_path

    expect(page).to have_text("6 utilisateurs | Page 1 sur 1")

    # Checkboxes should be present to select users
    #
    within :table_row, { "Utilisateur" => "Marc Debomy" } do
      check
    end

    # A message should diplay the number of selected users
    # with a button to remove them
    #
    within ".header-bar--selection", text: "1 utilisateur sélectionné" do
      click_on "Supprimer la sélection"
    end

    # A confirmation dialog should appears
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer l'utilisateur sélectionné ?" do
      click_on "Continuer"
    end

    # The browser should stay on index page
    # The selected users should not appears anymore
    # Other users should remain
    #
    expect(page).to     have_current_path(users_path)
    expect(page).to     have_selector("h1", text: "Utilisateurs")
    expect(page).to     have_text("5 utilisateurs | Page 1 sur 1")
    expect(page).not_to have_selector(:table_row, "Utilisateur" => "Marc Debomy")
    expect(page).to     have_selector(:table_row, "Utilisateur" => "Maxime Gauthier")
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

    # The browser should stay on index page
    # The remove users should be back again
    #
    expect(page).to have_current_path(users_path)
    expect(page).to have_selector("h1", text: "Utilisateurs")
    expect(page).to have_text("6 utilisateurs | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Marc Debomy")

    # The selection message should not appears again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=alert]", text: "Les utilisateurs sélectionnés ont été supprimés.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression des utilisateurs sélectionnés a été annulée.")
  end

  it "selects and discards all users from the current page on index page and then rollbacks" do
    # Create a bunch of users to have several pages
    # Create discarded users to verify they are not rollbacked
    #
    create_list(:user, 10, :using_existing_organizations)
    create_list(:user, 5, :using_existing_organizations, :discarded)

    visit users_path

    expect(page).to have_text("16 utilisateurs | Page 1 sur 1")

    # Paginate users by 10
    # More than one page should exist
    #
    click_on "Options d'affichage"
    click_on "Afficher 50 lignes par page"
    click_on "Afficher 10 lignes"

    expect(page).to have_text("16 utilisateurs | Page 1 sur 2")

    # Checkboxes should be present to select all users
    #
    within :table do
      check nil, match: :first
    end

    # A message should diplay the number of selected users
    # with a button to remove them
    #
    within ".header-bar--selection", text: "10 utilisateurs sélectionnés" do
      click_on "Supprimer la sélection"
    end

    # A confirmation dialog should appears
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer les 10 utilisateurs sélectionnés ?" do
      click_on "Continuer"
    end

    # The browser should stay on index page
    # The selected users should have been removed
    #
    expect(page).to     have_current_path(users_path)
    expect(page).to     have_selector("h1", text: "Utilisateurs")
    expect(page).to     have_text("6 utilisateurs | Page 1 sur 1")
    expect(page).not_to have_selector(:table_row, "Utilisateur" => "Marc Debomy")
    expect(page).not_to have_selector(:table_row, "Utilisateur" => "Maxime Gauthier")
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

    # The browser should stay on index page
    # All users should be back again
    #
    expect(page).to have_current_path(users_path)
    expect(page).to have_selector("h1", text: "Utilisateurs")
    expect(page).to have_text("16 utilisateurs | Page 1 sur 2")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Marc Debomy")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Maxime Gauthier")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Christelle Droitier")

    # The selection message should not appears again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=alert]", text: "Les utilisateurs sélectionnés ont été supprimés.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression des utilisateurs sélectionnés a été annulée.")
  end

  it "selects and discards all users through several pages on index page and then rollbacks" do
    # Create a bunch of users to have several pages
    # TODO: Create discarded users to verify they are not rollbacked
    #
    create_list(:user, 10, :using_existing_organizations)

    visit users_path

    expect(page).to have_text("16 utilisateurs | Page 1 sur 1")

    # Paginate users by 10
    # More than one page should exist
    #
    click_on "Options d'affichage"
    click_on "Afficher 50 lignes par page"
    click_on "Afficher 10 lignes"

    expect(page).to have_text("16 utilisateurs | Page 1 sur 2")

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
      click_on "Sélectionner les 16 utilisateurs des 2 pages"
    end

    within ".header-bar--selection", text: "16 utilisateurs sélectionnés" do
      click_on "Supprimer la sélection"
    end

    # A confirmation dialog should appears
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer les 16 utilisateurs sélectionnés ?" do
      click_on "Continuer"
    end

    # The browser should stay on index page
    # No users should appears anymore
    #
    expect(page).to have_current_path(users_path)
    expect(page).to have_selector("h1", text: "Utilisateurs")
    expect(page).to have_text("Aucun utilisateur disponible")

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

    # The browser should stay on index page
    # All users should be back again
    #
    expect(page).to have_current_path(users_path)
    expect(page).to have_selector("h1", text: "Utilisateurs")
    expect(page).to have_text("16 utilisateurs | Page 1 sur 2")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Marc Debomy")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Maxime Gauthier")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Christelle Droitier")

    # The selection message should not appears again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=alert]", text: "Les utilisateurs sélectionnés ont été supprimés.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression des utilisateurs sélectionnés a été annulée.")
  end
end
