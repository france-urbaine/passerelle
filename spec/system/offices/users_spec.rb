# frozen_string_literal: true

require "system_helper"

RSpec.describe "Office users" do
  fixtures :regions, :departements, :epcis, :communes
  fixtures :publishers, :collectivities, :ddfips, :offices
  fixtures :users, :office_users

  let(:ddfip64)      { ddfips(:pyrenees_atlantiques) }
  let(:pelp_bayonne) { offices(:pelp_bayonne) }
  let(:sip_bayonne)  { offices(:sip_bayonne) }
  let(:maxime)       { users(:maxime) }

  it "visits an user page from the office page" do
    visit office_path(pelp_bayonne)

    # A table of users should be present
    # with a link to their details page
    #
    expect(page).to have_selector(:table_row, "Utilisateur" => "Maxime Gauthier")

    click_on "Maxime Gauthier"

    # The browser should have been redirected to the user page
    #
    expect(page).to have_current_path(user_path(maxime))
    expect(page).to have_selector("h1", text: "Maxime Gauthier")

    go_back

    # The browser should have redirect back to office page
    #
    expect(page).to have_current_path(office_path(pelp_bayonne))
    expect(page).to have_selector("h1", text: "PELP de Bayonne")
  end

  it "paginate users on publisher page" do
    # Create enough users to have several pages
    #
    create_list(:user, 10, organization: ddfip64, offices: [pelp_bayonne])

    visit office_path(pelp_bayonne)

    expect(page).to     have_text("11 utilisateurs | Page 1 sur 2")
    expect(page).not_to have_button("Options d'affichage")
  end

  it "invites an user from the office page" do
    visit office_path(pelp_bayonne)

    # A button should be present to add a new user
    #
    click_on "Inviter un utilisateur"

    # A dialog box should appears with a form to fill
    #
    within "[role=dialog]", text: "Invitation d'un nouvel utilisateur" do |dialog|
      expect(dialog).to have_field("Organisation", with: "DDFIP des Pyrénées-Atlantiques")
      expect(dialog).to have_field("Prénom")
      expect(dialog).to have_field("Nom")
      expect(dialog).to have_field("Adresse mail")
      expect(dialog).to have_unchecked_field("Administrateur de l'organisation")
      expect(dialog).to have_unchecked_field("Administrateur de la plateforme FiscaHub")

      within ".form-block", text: "Guichets" do |block|
        expect(block).to have_checked_field("PELP de Bayonne")
        expect(block).to have_unchecked_field("PELH de Bayonne")
        expect(block).to have_unchecked_field("SIP de Bayonne")
      end

      fill_in "Prénom",       with: "Elliot"
      fill_in "Nom",          with: "Alderson"
      fill_in "Adresse mail", with: "robot@fiscalite-territoire.fr"

      click_on "Enregistrer"
    end

    # The browser should stay on office page
    # The new user should appears
    #
    expect(page).to have_current_path(office_path(pelp_bayonne))
    expect(page).to have_selector("h1", text: "PELP de Bayonne")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Elliot Alderson")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Un nouvel utilisateur a été ajouté avec succés.")
  end

  it "updates an user from the office page" do
    visit office_path(pelp_bayonne)

    # A table of users should be present
    # with a button to edit them
    #
    within :table_row, { "Utilisateur" => "Maxime Gauthier" } do
      click_on "Modifier cet utilisateur"
    end

    # A dialog box should appears with a form
    # The form should be filled with user data
    #
    within "[role=dialog]", text: "Modification de l'utilisateur" do |dialog|
      expect(dialog).to have_field("Organisation", with: "DDFIP des Pyrénées-Atlantiques")
      expect(dialog).to have_field("Prénom",       with: "Maxime")
      expect(dialog).to have_field("Nom",          with: "Gauthier")
      expect(dialog).to have_field("Adresse mail", with: "maxime.gauthier@dgfip.finances.gouv.fr")
      expect(dialog).to have_unchecked_field("Administrateur de l'organisation")
      expect(dialog).to have_unchecked_field("Administrateur de la plateforme FiscaHub")

      within ".form-block", text: "Guichets" do |block|
        expect(block).to have_checked_field("PELP de Bayonne")
        expect(block).to have_unchecked_field("PELH de Bayonne")
        expect(block).to have_unchecked_field("SIP de Bayonne")
      end

      fill_in "Nom", with: "Gaultier"

      click_on "Enregistrer"
    end

    # The browser should stay on office page
    # The user's name should have been updated
    #
    expect(page).to have_current_path(office_path(pelp_bayonne))
    expect(page).to have_selector("h1", text: "PELP de Bayonne")
    expect(page).to have_selector(:table_row, { "Utilisateur" => "Maxime Gaultier" })

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "manages users from the office page" do
    visit office_path(sip_bayonne)

    # The users list should be empty
    #
    expect(page).to have_text("Aucun utilisateur assigné à ce guichet.")

    # A button should be present to manage users
    #
    click_on "Gérer les utilisateurs"

    # A dialog box should appears with a form
    # The form should be filled with office data
    #
    within "[role=dialog]", text: "Gestion des utilisateurs du guichet" do |dialog|
      expect(dialog).to have_unchecked_field("Maxime Gauthier")
      expect(dialog).to have_unchecked_field("Astride Fabre")

      check "Astride Fabre"

      click_on "Enregistrer"
    end

    # The browser should stay on office page
    # The new user should appears
    #
    expect(page).to have_current_path(office_path(sip_bayonne))
    expect(page).to have_selector("h1", text: "SIP de Bayonne")
    expect(page).to have_text("1 utilisateur | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Astride Fabre")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")

    # Re-open the modal to add another user
    #
    click_on "Gérer les utilisateurs"

    within "[role=dialog]", text: "Gestion des utilisateurs du guichet" do |dialog|
      expect(dialog).to have_unchecked_field("Maxime Gauthier")
      expect(dialog).to have_checked_field("Astride Fabre")

      check "Maxime Gauthier"

      click_on "Enregistrer"
    end

    # The browser should stay on office page
    # The new user should appears
    #
    expect(page).to have_current_path(office_path(sip_bayonne))
    expect(page).to have_selector("h1", text: "SIP de Bayonne")
    expect(page).to have_text("2 utilisateurs | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Astride Fabre")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Maxime Gauthier")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.", count: 1)

    # Re-open the modal to remove all users
    #
    click_on "Gérer les utilisateurs"

    within "[role=dialog]", text: "Gestion des utilisateurs du guichet" do |dialog|
      expect(dialog).to have_checked_field("Maxime Gauthier")
      expect(dialog).to have_checked_field("Astride Fabre")

      uncheck "Maxime Gauthier"
      uncheck "Astride Fabre"

      click_on "Enregistrer"
    end

    # The browser should stay on office page
    # No users should appears
    #
    expect(page).to have_current_path(office_path(sip_bayonne))
    expect(page).to have_selector("h1", text: "SIP de Bayonne")
    expect(page).to have_text("Aucun utilisateur assigné à ce guichet.")
  end

  it "removes an user from the office without discarding it" do
    visit office_path(pelp_bayonne)

    # A table of users should be present
    # with a button to edit them
    #
    within :table_row, { "Utilisateur" => "Maxime Gauthier" } do
      click_on "Exclure cet utilisateur du guichet"
    end

    # A confirmation dialog should appears
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir exclure cet utilisateur du guichet ?" do
      click_on "Continuer"
    end

    # The browser should stay on office page
    # The user should not appears anymore
    expect(page).to     have_current_path(office_path(pelp_bayonne))
    expect(page).to     have_selector("h1", text: "PELP de Bayonne")
    expect(page).not_to have_selector(:table_row, "Utilisateur" => "Maxime Gauthier")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "L'utilisateur a été exclus du guichet.")

    # The user should still exists in database
    #
    expect(ddfip64.users.kept).to include(maxime)
  end

  it "selects and removes one user from the office page" do
    visit office_path(pelp_bayonne)

    # Checkboxes should be present to select users
    #
    within :table_row, { "Utilisateur" => "Maxime Gauthier" } do
      check
    end

    # A message should diplay the number of selected users
    # with a button to remove them
    #
    within ".header-bar--selection", text: "1 utilisateur sélectionné" do
      click_on "Exclure les utilisateurs du guichet"
    end

    # A confirmation dialog should appears
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir exclure l'utilisateur sélectionné du guichet ?" do
      click_on "Continuer"
    end

    # The browser should stay on index page
    # The selected users should not appears anymore
    # Other users should remain
    #
    expect(page).to     have_current_path(office_path(pelp_bayonne))
    expect(page).to     have_selector("h1", text: "PELP de Bayonne")
    expect(page).not_to have_selector(:table_row, "Utilisateur" => "Maxime Gauthier")

    # The selection message should not appears anymore
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).not_to have_selector(".header-bar--selection")
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les utilisateurs sélectionnés ont été exclus du guichet.")
  end

  it "deletes an user from the office page and then rollbacks" do
    visit office_path(pelp_bayonne)

    # A table of users should be present
    # with a button to remove them
    #
    within :table_row, { "Utilisateur" => "Maxime Gauthier" } do
      click_on "Supprimer cet utilisateur"
    end

    # A confirmation dialog should appears
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer cet utilisateur ?" do
      click_on "Continuer"
    end

    # The browser should stay on publisher page
    # The user should not appears anymore
    #
    expect(page).to     have_current_path(office_path(pelp_bayonne))
    expect(page).to     have_selector("h1", text: "PELP de Bayonne")
    expect(page).not_to have_selector(:table_row, "Utilisateur" => "Maxime Gauthier")

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

    # The browser should stay on publisher page
    # The user should not appears anymore
    # The user should be back again
    #
    expect(page).to have_current_path(office_path(pelp_bayonne))
    expect(page).to have_selector("h1", text: "PELP de Bayonne")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Maxime Gauthier")

    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).not_to have_selector("[role=alert]", text: "L'utilisateur a été supprimé.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression de l'utilisateur a été annulée.")
  end
end
