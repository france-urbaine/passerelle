# frozen_string_literal: true

require "system_helper"

RSpec.describe "Manage users from organization" do
  fixtures :all

  let(:marc)       { users(:marc) }
  let(:elise)      { users(:elise) }
  let(:christelle) { users(:christelle) }
  let(:maxime)     { users(:maxime) }

  context "when organization is a publisher" do
    before { sign_in(marc) }

    it "visits index & user pages" do
      visit organization_users_path

      # A table of all organization users should be present
      #
      expect(page).to have_selector("h1", text: "Équipe")
      expect(page).to have_text("3 utilisateurs | Page 1 sur 1")
      expect(page).to have_selector(:table_row, "Utilisateur" => "Marc Debomy")
      expect(page).to have_selector(:table_row, "Utilisateur" => "Elise Lacroix")

      click_on "Marc Debomy"

      # The browser should visit the user page
      #
      expect(page).to have_current_path(organization_user_path(marc))
      expect(page).to have_selector("h1", text: "Marc Debomy")

      go_back

      # The browser should redirect back to the index page
      #
      expect(page).to have_current_path(organization_users_path)
      expect(page).to have_selector("h1", text: "Équipe")
    end

    it "visits the links on a user page" do
      visit organization_user_path(marc)

      # On the user page, we expect only one email link.
      # It should not have link to organization
      #
      # Scope to main content to exclude link from the navbar
      #
      within "main.content" do
        expect(page).to have_selector("h1", text: "Marc Debomy")
        expect(page).to have_link("mdebomy@solutions-territoire.fr")
        expect(page).to have_no_link("Solutions & Territoire")
      end
    end

    it "resets a user from the user page" do
      visit organization_user_path(elise)

      expect(page).to have_selector("a.button", text: "Réinitialiser")

      click_on "Réinitialiser"

      within "[role=dialog]", text: "Réinitialisation de l'utilisateur" do
        click_on "Continuer"
      end

      expect(page).to have_current_path(organization_user_path(elise))

      # The dialog should be closed
      # A notification should be displayed
      #
      expect(page).to have_no_selector("[role=dialog]")
      expect(page).to have_selector("[role=log]", text: "L'invitation a été envoyée.")
      expect(page).to have_no_selector("a.button", text: "Réinitialiser")
      expect(page).to have_selector("a.button", text: "Renouveler l'invitation")
    end

    it "does not display reset button on user self page" do
      visit organization_user_path(marc)

      expect(page).to have_selector("a.button")
      expect(page).to have_no_selector("a.button", text: "Réinitialiser")
    end

    it "invites an user from the index page" do
      visit organization_users_path

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
        fill_in "Adresse mail", with: "robot@solutions-territoire.fr"

        click_on "Enregistrer"
      end

      # The browser should stay on the index page
      # The new user should appear
      #
      expect(page).to have_current_path(organization_users_path)
      expect(page).to have_selector("h1", text: "Équipe")
      expect(page).to have_selector(:table_row, "Utilisateur" => "Elliot Alderson")

      # The dialog should be closed
      # A notification should be displayed
      #
      expect(page).to have_no_selector("[role=dialog]")
      expect(page).to have_selector("[role=log]", text: "Un nouvel utilisateur a été ajouté avec succés.")
    end

    it "updates an user from the index page" do
      visit organization_users_path

      # A button should be present to edit the user
      #
      within :table_row, { "Utilisateur" => "Marc Debomy" } do
        click_on "Modifier cet utilisateur"
      end

      # A dialog box should appear with a form
      # The form should be filled with user data
      #
      within "[role=dialog]", text: "Modification de l'utilisateur" do |dialog|
        expect(dialog).to have_no_field("Organisation")
        expect(dialog).to have_field("Prénom",       with: "Marc")
        expect(dialog).to have_field("Nom",          with: "Debomy")
        expect(dialog).to have_field("Adresse mail", with: "mdebomy@solutions-territoire.fr")
        expect(dialog).to have_checked_field("Administrateur de l'organisation")

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
        fill_in "Prénom", with: "Marc-André"
        fill_in "Nom",    with: "De Bomy"

        click_on "Enregistrer"
      end

      # The browser should stay on the index page
      # The user should have changed its name
      #
      expect(page).to have_current_path(organization_users_path)
      expect(page).to have_selector("h1", text: "Équipe")
      expect(page).to have_selector(:table_row, "Utilisateur" => "Marc-André De Bomy")

      # The dialog should be closed
      # A notification should be displayed
      #
      expect(page).to have_no_selector("[role=dialog]")
      expect(page).to have_selector("[role=log]", text: "Les modifications ont été enregistrées avec succés.")
    end

    it "updates an user from the user page" do
      visit organization_user_path(marc)

      # A button should be present to edit the user
      #
      within ".breadcrumbs", text: "Marc Debomy" do
        click_on "Modifier"
      end

      # A dialog box should appear with a form
      # The form should be filled with user data
      #
      within "[role=dialog]", text: "Modification de l'utilisateur" do |dialog|
        expect(dialog).to have_no_field("Organisation")
        expect(dialog).to have_field("Prénom",       with: "Marc")
        expect(dialog).to have_field("Nom",          with: "Debomy")
        expect(dialog).to have_field("Adresse mail", with: "mdebomy@solutions-territoire.fr")
        expect(dialog).to have_checked_field("Administrateur de l'organisation")

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
        fill_in "Prénom", with: "Marc-André"
        fill_in "Nom",    with: "De Bomy"

        click_on "Enregistrer"
      end

      # The browser should stay on the user page
      # The user should have changed its name
      #
      expect(page).to have_current_path(organization_user_path(marc))
      expect(page).to have_selector("h1", text: "Marc-André De Bomy")

      # The dialog should be closed
      # A notification should be displayed
      #
      expect(page).to have_no_selector("[role=dialog]")
      expect(page).to have_selector("[role=log]", text: "Les modifications ont été enregistrées avec succés.")
    end

    it "discards an user from the index page & rollbacks" do
      visit organization_users_path

      expect(page).to have_text("3 utilisateurs | Page 1 sur 1")

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
      # The user should not appear anymore
      #
      expect(page).to have_current_path(organization_users_path)
      expect(page).to have_selector("h1", text: "Équipe")
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

      # The browser should stay on the index page
      # The user should be back again
      #
      expect(page).to have_current_path(organization_users_path)
      expect(page).to have_selector("h1", text: "Équipe")
      expect(page).to have_text("3 utilisateurs | Page 1 sur 1")
      expect(page).to have_selector(:table_row, "Utilisateur" => "Elise Lacroix")

      # The previous notification should be closed
      # A new notification should be displayed
      #
      expect(page).to have_no_selector("[role=log]", text: "L'utilisateur a été supprimé.")
      expect(page).to have_selector("[role=log]", text: "La suppression de l'utilisateur a été annulée.")
    end

    it "discards an user from the user page & rollbacks" do
      visit organization_user_path(elise)

      # A button should be present to edit the user
      #
      within ".breadcrumbs", text: "Elise Lacroix" do
        click_on "Supprimer"
      end

      # A confirmation dialog should appear
      #
      within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer cet utilisateur ?" do
        click_on "Continuer"
      end

      # The browser should redirect to the index page
      # The user should not appear anymore
      #
      expect(page).to have_current_path(organization_users_path)
      expect(page).to have_selector("h1", text: "Équipe")
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

      # The browser should stay on the index page
      # The user should be back again
      #
      expect(page).to have_current_path(organization_users_path)
      expect(page).to have_selector("h1", text: "Équipe")
      expect(page).to have_text("3 utilisateurs | Page 1 sur 1")
      expect(page).to have_selector(:table_row, "Utilisateur" => "Elise Lacroix")

      # The previous notification should be closed
      # A new notification should be displayed
      #
      expect(page).to have_no_selector("[role=log]", text: "L'utilisateur a été supprimé.")
      expect(page).to have_selector("[role=log]", text: "La suppression de l'utilisateur a été annulée.")
    end

    it "discards himself and been disconnected" do
      visit organization_users_path

      expect(page).to have_text("3 utilisateurs | Page 1 sur 1")

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
      # The dialog should have disappeared
      #
      expect(page).to have_current_path(new_user_session_path)
      expect(page).to have_no_selector("[role=dialog]")
    end

    it "selects and discards one user from the index page & rollbacks" do
      visit organization_users_path

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

      # The browser should stay on index page
      # The selected users should not appear anymore
      # Other users should remain
      #
      expect(page).to have_current_path(organization_users_path)
      expect(page).to have_selector("h1", text: "Équipe")
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

      # The browser should stay on index page
      # The remove users should be back again
      #
      expect(page).to have_current_path(organization_users_path)
      expect(page).to have_selector("h1", text: "Équipe")
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

    it "selects and discards all users but himself from the current page on index page & rollbacks" do
      # Create a bunch of users to have several pages
      # Create discarded users to verify they are not rollbacked
      #
      publisher = publishers(:solutions_territoire)
      create_list(:user, 10, organization: publisher)
      create_list(:user, 5, :discarded, organization: publisher)

      visit organization_users_path

      expect(page).to have_text("13 utilisateurs | Page 1 sur 1")

      # Paginate users by 10
      # More than one page should exist
      #
      click_on "Options d'affichage"
      click_on "Afficher 50 lignes par page"
      click_on "Afficher 10 lignes"

      expect(page).to have_text("13 utilisateurs | Page 1 sur 2")

      # Checkboxes should be present to select all users
      #
      within :table do
        check nil, match: :first
      end

      within :table_row, { "Utilisateur" => "Marc Debomy" } do
        uncheck
      end

      # A message should diplay the number of selected users
      # with a button to remove them
      #
      within ".datatable__selection", text: "9 utilisateurs sélectionnés" do
        click_on "Tout supprimer"
      end

      # A confirmation dialog should appear
      #
      within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer les 9 utilisateurs sélectionnés ?" do
        click_on "Continuer"
      end

      # The browser should stay on index page
      # The selected users should have been removed
      # The current user should not have been removed
      #
      expect(page).to have_current_path(organization_users_path)
      expect(page).to have_selector("h1", text: "Équipe")
      expect(page).to have_text("4 utilisateurs | Page 1 sur 1")
      expect(page).to have_selector(:table_row, "Utilisateur" => "Marc Debomy")

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

      # The browser should stay on index page
      # All users should be back again
      #
      expect(page).to have_current_path(organization_users_path)
      expect(page).to have_selector("h1", text: "Équipe")
      expect(page).to have_text("13 utilisateurs | Page 1 sur 2")
      expect(page).to have_selector(:table_row, "Utilisateur" => "Marc Debomy")
      expect(page).to have_selector(:table_row, "Utilisateur" => "Elise Lacroix")

      # The selection message should not appear again
      # The previous notification should be closed
      # A new notification should be displayed
      #
      expect(page).to have_no_selector(".datatable__selection")
      expect(page).to have_no_selector("[role=log]", text: "Les utilisateurs sélectionnés ont été supprimés.")
      expect(page).to have_selector("[role=log]", text: "La suppression des utilisateurs sélectionnés a été annulée.")
    end

    it "selects and discards all users including himself through several pages on index page and been disconnected" do
      # Create a bunch of users to have several pages
      # TODO: Create discarded users to verify they are not rollbacked
      #
      publisher = publishers(:solutions_territoire)
      create_list(:user, 10, organization: publisher)

      visit organization_users_path

      expect(page).to have_text("13 utilisateurs | Page 1 sur 1")

      # Paginate users by 10
      # More than one page should exist
      #
      click_on "Options d'affichage"
      click_on "Afficher 50 lignes par page"
      click_on "Afficher 10 lignes"

      expect(page).to have_text("13 utilisateurs | Page 1 sur 2")

      # Checkboxes should be present to select all users
      #
      within :table do
        check nil, match: :first
      end

      # A message should diplay the number of selected users
      # A link to select any users from any page should be present
      # A link to remove all of them should be present
      #
      within ".datatable__selection", text: "10 utilisateurs sélectionnés" do
        click_on "Sélectionner les 13 utilisateurs des 2 pages"
      end

      within ".datatable__selection", text: "13 utilisateurs sélectionnés" do
        click_on "Tout supprimer"
      end

      # A confirmation dialog should appear
      #
      pending "TODO: display a proper message when current user is selected"

      within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer les 13 utilisateurs sélectionnés ?" do |dialog|
        expect(dialog).to have_text("Attention : votre compte utilisateur est inclus dans la liste")
        click_on "Continuer"
      end

      # The browser should sign out and redirect to login form
      # The dialog should have disappeared
      #
      expect(page).to have_current_path(new_user_session_path)
      expect(page).to have_no_selector("[role=dialog]")
    end
  end

  context "when organization is a collectivity" do
    before { sign_in(christelle) }

    it "visits index & user pages" do
      visit organization_users_path

      # A table of all users should be present
      #
      expect(page).to have_selector("h1", text: "Équipe")
      expect(page).to have_text("2 utilisateurs | Page 1 sur 1")
      expect(page).to have_selector(:table_row, "Utilisateur" => "Christelle Droitier")
      expect(page).to have_selector(:table_row, "Utilisateur" => "Pierre Civil")

      click_on "Christelle Droitier"

      # The browser should visit the user page
      #
      expect(page).to have_current_path(organization_user_path(christelle))
      expect(page).to have_selector("h1", text: "Christelle Droitier")

      go_back

      # The browser should redirect back to the index page
      #
      expect(page).to have_current_path(organization_users_path)
      expect(page).to have_selector("h1", text: "Équipe")
    end

    it "visits the user page to identify links" do
      visit organization_user_path(christelle)

      # On the user page, we expect only one email link.
      # It should not have link to organization
      #
      # Scope to main content to exclude link from the navbar
      #
      within "main.content" do
        expect(page).to have_selector("h1", text: "Christelle Droitier")
        expect(page).to have_link("christelle.droitier@paysbasque.fr")
        expect(page).to have_no_link("CA du Pays Basque")
      end
    end
  end

  context "when organization is a DDFIP" do
    before { sign_in(maxime) }

    it "visits index & user pages" do
      visit organization_users_path

      # A table of all users should be present
      #
      expect(page).to have_selector("h1", text: "Équipe")
      expect(page).to have_text("2 utilisateurs | Page 1 sur 1")
      expect(page).to have_selector(:table_row, "Utilisateur" => "Maxime Gauthier")
      expect(page).to have_selector(:table_row, "Utilisateur" => "Astride Fabre")

      click_on "Maxime Gauthier"

      # The browser should visit the user page
      #
      expect(page).to have_current_path(organization_user_path(maxime))
      expect(page).to have_selector("h1", text: "Maxime Gauthier")

      go_back

      # The browser should redirect back to the index page
      #
      expect(page).to have_current_path(organization_users_path)
      expect(page).to have_selector("h1", text: "Équipe")
    end

    it "visits the user page to identify links" do
      visit organization_user_path(maxime)

      # On the user page, we expect only one email link.
      # It should  have links to offices
      #
      expect(page).to have_selector("h1", text: "Maxime Gauthier")
      expect(page).to have_link("maxime.gauthier@dgfip.finances.gouv.fr")
      expect(page).to have_link("PELP de Bayonne")
    end

    it "invites an user from the index page to join some offices" do
      visit organization_users_path

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

        within ".form-block", text: "Guichets" do |block|
          expect(block).to have_unchecked_field("PELP de Bayonne")
          expect(block).to have_unchecked_field("PELH de Bayonne")
          expect(block).to have_unchecked_field("SIP de Bayonne")
        end

        fill_in "Prénom",       with: "Elliot"
        fill_in "Nom",          with: "Alderson"
        fill_in "Adresse mail", with: "robot@solutions-territoire.fr"

        check "PELP de Bayonne"
        check "PELH de Bayonne"

        click_on "Enregistrer"
      end

      # The browser should stay on the index page
      # The new user should appear
      #
      expect(page).to have_current_path(organization_users_path)
      expect(page).to have_selector("h1", text: "Équipe")
      expect(page).to have_selector(:table_row, "Utilisateur" => "Elliot Alderson")

      # The dialog should be closed
      # A notification should be displayed
      #
      expect(page).to have_no_selector("[role=dialog]")
      expect(page).to have_selector("[role=log]", text: "Un nouvel utilisateur a été ajouté avec succés.")

      # The new user should belong to checked offices
      #
      expect(User.last.offices)
        .to include(offices(:pelp_bayonne))
        .and include(offices(:pelh_bayonne))
        .and not_include(offices(:sip_bayonne))
    end

    it "updates an user offices" do
      visit organization_user_path(maxime)

      expect(page).to have_link("PELP de Bayonne")
      expect(page).to have_no_link("PELH de Bayonne")
      expect(page).to have_no_link("SIP de Bayonne")

      # A button should be present to edit the user
      #
      within ".breadcrumbs", text: "Maxime Gauthier" do
        click_on "Modifier"
      end

      # A dialog box should appear with a form
      # The form should be filled with user data
      #
      within "[role=dialog]", text: "Modification de l'utilisateur" do
        within ".form-block", text: "Guichets" do |block|
          expect(block).to have_checked_field("PELP de Bayonne")
          expect(block).to have_unchecked_field("PELH de Bayonne")
          expect(block).to have_unchecked_field("SIP de Bayonne")
        end

        uncheck "PELP de Bayonne"
        check "PELH de Bayonne"
        check "SIP de Bayonne"

        click_on "Enregistrer"
      end

      # The browser should stay on the user page
      # The user offices should have been updated
      #
      expect(page).to have_current_path(organization_user_path(maxime))
      expect(page).to have_selector("h1", text: "Maxime Gauthier")
      expect(page).to have_no_link("PELP de Bayonne")
      expect(page).to have_link("PELH de Bayonne")
      expect(page).to have_link("SIP de Bayonne")
    end
  end
end
