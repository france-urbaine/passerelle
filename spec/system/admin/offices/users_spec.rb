# frozen_string_literal: true

require "system_helper"

RSpec.describe "Office users in admin" do
  fixtures :regions, :departements, :epcis, :communes
  fixtures :publishers, :collectivities, :ddfips, :offices
  fixtures :users, :office_users

  let(:ddfip64)      { ddfips(:pyrenees_atlantiques) }
  let(:pelp_bayonne) { offices(:pelp_bayonne) }
  let(:sip_bayonne)  { offices(:sip_bayonne) }
  let(:maxime)       { users(:maxime) }

  before { sign_in(users(:marc)) }

  it "visits an user page from the office page" do
    visit admin_office_path(pelp_bayonne)

    # A table of users should be present
    #
    expect(page).to have_selector("h1", text: "PELP de Bayonne")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Maxime Gauthier")

    click_on "Maxime Gauthier"

    # The browser should visit the user page
    #
    expect(page).to have_current_path(admin_user_path(maxime))
    expect(page).to have_selector("h1", text: "Maxime Gauthier")

    go_back

    # The browser should have redirect back to the office page
    #
    expect(page).to have_current_path(admin_office_path(pelp_bayonne))
    expect(page).to have_selector("h1", text: "PELP de Bayonne")
  end

  it "paginate users on the office page" do
    # Create enough users to have several pages
    #
    pelp_bayonne.users << create_list(:user, 10, organization: ddfip64)

    visit admin_office_path(pelp_bayonne)

    expect(page).to have_text("13 utilisateurs | Page 1 sur 2")
    expect(page).to have_no_button("Options d'affichage")
  end

  it "invites an user from the office page" do
    visit admin_office_path(pelp_bayonne)

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

      within ".form-block", text: "Guichets" do |block|
        expect(block).to have_checked_field("PELP de Bayonne")
        expect(block).to have_unchecked_field("Superviseur")
        expect(block).to have_unchecked_field("PELH de Bayonne")
        expect(block).to have_unchecked_field("SIP de Bayonne")
      end

      fill_in "Prénom",       with: "Elliot"
      fill_in "Nom",          with: "Alderson"
      fill_in "Adresse mail", with: "robot@solutions-territoire.fr"

      click_on "Enregistrer"
    end

    # The browser should stay on the office page
    # The new user should appear
    #
    expect(page).to have_current_path(admin_office_path(pelp_bayonne))
    expect(page).to have_selector("h1", text: "PELP de Bayonne")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Elliot Alderson")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to have_no_selector("[role=dialog]")
    expect(page).to have_selector("[role=log]", text: "Un nouvel utilisateur a été ajouté avec succés.")
  end

  it "updates an user from the office page" do
    visit admin_office_path(pelp_bayonne)

    # A table of users should be present
    # with a button to edit them
    #
    within :table_row, { "Utilisateur" => "Maxime Gauthier" } do
      click_on "Modifier cet utilisateur"
    end

    # A dialog box should appear with a form
    # The form should be filled with user data
    #
    within "[role=dialog]", text: "Modification de l'utilisateur" do |dialog|
      expect(dialog).to have_field("Organisation", with: "DDFIP des Pyrénées-Atlantiques")
      expect(dialog).to have_field("Prénom",       with: "Maxime")
      expect(dialog).to have_field("Nom",          with: "Gauthier")
      expect(dialog).to have_field("Adresse mail", with: "maxime.gauthier@dgfip.finances.gouv.fr")
      expect(dialog).to have_checked_field("Administrateur de l'organisation")
      expect(dialog).to have_unchecked_field("Administrateur de la plateforme Passerelle")

      dialog.find("label", exact_text: "Guichets").sibling(".choices-collection") do |block|
        expect(block).to have_checked_field("PELP de Bayonne")
        expect(block).to have_unchecked_field("Superviseur")
        expect(block).to have_unchecked_field("PELH de Bayonne")
        expect(block).to have_unchecked_field("SIP de Bayonne")
      end

      within(:xpath, '//label[text()="Référent"]/following-sibling::div[1]') do |block|
        expect(block).to have_checked_field("Évaluation d'un local d'habitation",  disabled: true)
        expect(block).to have_checked_field("Évaluation d'un local professionnel", disabled: true)
        expect(block).to have_checked_field("Création d'un local d'habitation",    disabled: true)
        expect(block).to have_checked_field("Création d'un local professionnel",   disabled: true)
        expect(block).to have_checked_field("Occupation d'un local d'habitation",  disabled: true)
        expect(block).to have_checked_field("Occupation d'un local professionnel", disabled: true)
      end

      fill_in "Nom", with: "Gaultier"

      click_on "Enregistrer"
    end

    # The browser should stay on the office page
    # The user's name should have been updated
    #
    expect(page).to have_current_path(admin_office_path(pelp_bayonne))
    expect(page).to have_selector("h1", text: "PELP de Bayonne")
    expect(page).to have_selector(:table_row, { "Utilisateur" => "Maxime Gaultier" })

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to have_no_selector("[role=dialog]")
    expect(page).to have_selector("[role=log]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "manages users from the office page" do
    visit admin_office_path(sip_bayonne)

    # The users list should be empty
    #
    expect(page).to have_text("Aucun utilisateur assigné à ce guichet.")

    # A button should be present to manage users
    #
    click_on "Gérer les utilisateurs"

    # A dialog box should appear with checkboxes
    # The checkboxes should allow to check DDIFP users
    #
    within "[role=dialog]", text: "Gestion des utilisateurs du guichet" do |dialog|
      expect(dialog).to have_unchecked_field("Maxime Gauthier")
      expect(dialog).to have_unchecked_field("Astride Fabre")

      check "Astride Fabre"

      click_on "Enregistrer"
    end

    # The browser should stay on the office page
    # The new user should appear
    #
    expect(page).to have_current_path(admin_office_path(sip_bayonne))
    expect(page).to have_selector("h1", text: "SIP de Bayonne")
    expect(page).to have_text("1 utilisateur | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Astride Fabre")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to have_no_selector("[role=dialog]")
    expect(page).to have_selector("[role=log]", text: "Les modifications ont été enregistrées avec succés.")

    # Re-open the modal to add another user
    #
    click_on "Gérer les utilisateurs"

    # A dialog box should appear with checkboxes
    # The checkboxes should be checked with assigned users
    #
    within "[role=dialog]", text: "Gestion des utilisateurs du guichet" do |dialog|
      expect(dialog).to have_unchecked_field("Maxime Gauthier")
      expect(dialog).to have_checked_field("Astride Fabre")

      check "Maxime Gauthier"

      click_on "Enregistrer"
    end

    # The browser should stay on the office page
    # The new user should appear
    #
    expect(page).to have_current_path(admin_office_path(sip_bayonne))
    expect(page).to have_selector("h1", text: "SIP de Bayonne")
    expect(page).to have_text("2 utilisateurs | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Astride Fabre")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Maxime Gauthier")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to have_no_selector("[role=dialog]")
    expect(page).to have_selector("[role=log]", text: "Les modifications ont été enregistrées avec succés.", count: 1)

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

    # The browser should stay on the office page
    # No users should appear
    #
    expect(page).to have_current_path(admin_office_path(sip_bayonne))
    expect(page).to have_selector("h1", text: "SIP de Bayonne")
    expect(page).to have_text("Aucun utilisateur assigné à ce guichet.")
  end

  it "excludes an user from the office without discarding it" do
    visit admin_office_path(pelp_bayonne)

    # A table of users should be present
    # with a button to exclude them
    #
    within :table_row, { "Utilisateur" => "Maxime Gauthier" } do
      click_on "Exclure cet utilisateur du guichet"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir exclure cet utilisateur du guichet ?" do
      click_on "Continuer"
    end

    # The browser should stay on the office page
    # The user should not appear anymore
    expect(page).to have_current_path(admin_office_path(pelp_bayonne))
    expect(page).to have_selector("h1", text: "PELP de Bayonne")
    expect(page).to have_no_selector(:table_row, "Utilisateur" => "Maxime Gauthier")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to have_no_selector("[role=dialog]")
    expect(page).to have_selector("[role=log]", text: "L'utilisateur a été exclu du guichet.")

    # The notification doesn't propose to rollback the last action
    #
    within "[role=log]", text: "L'utilisateur a été exclu du guichet." do |alert|
      expect(alert).to have_no_button("Cancel")
    end

    click_on "DDFIP des Pyrénées-Atlantiques"

    # The user should remains available on the DDFIP page
    #
    expect(page).to have_current_path(admin_ddfip_path(ddfip64))
    expect(page).to have_selector("h1", text: "DDFIP des Pyrénées-Atlantiques")
    expect(page).to have_text("5 utilisateurs | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Maxime Gauthier")
  end

  it "selects and excludes one user from the office page" do
    visit admin_office_path(pelp_bayonne)

    # Checkboxes should be present to select users
    #
    within :table_row, { "Utilisateur" => "Maxime Gauthier" } do
      check
    end

    # A message should diplay the number of selected users
    # with a button to remove them
    #
    within ".datatable__selection", text: "1 utilisateur sélectionné" do
      click_on "Tout exclure du guichet"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir exclure l'utilisateur sélectionné du guichet ?" do
      click_on "Continuer"
    end

    # The browser should stay on the office page
    # The selected users should not appear anymore
    # Other users should remain
    #
    expect(page).to have_current_path(admin_office_path(pelp_bayonne))
    expect(page).to have_selector("h1", text: "PELP de Bayonne")
    expect(page).to have_no_selector(:table_row, "Utilisateur" => "Maxime Gauthier")

    # The selection message should not appear anymore
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to have_no_selector(".datatable__selection")
    expect(page).to have_no_selector("[role=dialog]")
    expect(page).to have_selector("[role=log]", text: "Les utilisateurs sélectionnés ont été exclus du guichet.")

    # The notification doesn't propose to rollback the last action
    #
    within "[role=log]", text: "Les utilisateurs sélectionnés ont été exclus du guichet." do |alert|
      expect(alert).to have_no_button("Cancel")
    end

    click_on "DDFIP des Pyrénées-Atlantiques"

    # The user should remains available on the DDFIP page
    #
    expect(page).to have_current_path(admin_ddfip_path(ddfip64))
    expect(page).to have_selector("h1", text: "DDFIP des Pyrénées-Atlantiques")
    expect(page).to have_text("5 utilisateurs | Page 1 sur 1")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Maxime Gauthier")
  end

  it "selects and excludes all users from the current page on the office page without discarding them" do
    # Create a bunch of users to have several pages
    #
    pelp_bayonne.users << create_list(:user, 10, organization: ddfip64)

    visit admin_office_path(pelp_bayonne)

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
      click_on "Tout exclure du guichet"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir exclure les 10 utilisateurs sélectionnés du guichet ?" do
      click_on "Continuer"
    end

    # The browser should stay on the office page
    # The selected users should have been removed
    #
    expect(page).to have_current_path(admin_office_path(pelp_bayonne))
    expect(page).to have_selector("h1", text: "PELP de Bayonne")
    expect(page).to have_text("3 utilisateurs | Page 1 sur 1")
    expect(page).to have_no_selector(:table_row, "Utilisateur" => "Maxime Gauthier")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to have_no_selector(".datatable__selection")
    expect(page).to have_no_selector("[role=dialog]")
    expect(page).to have_selector("[role=log]", text: "Les utilisateurs sélectionnés ont été exclus du guichet.")

    # The notification doesn't propose to rollback the last action
    #
    within "[role=log]", text: "Les utilisateurs sélectionnés ont été exclus du guichet." do |alert|
      expect(alert).to have_no_button("Cancel")
    end

    click_on "DDFIP des Pyrénées-Atlantiques"

    # The user should remains available on the DDFIP page
    #
    expect(page).to have_current_path(admin_ddfip_path(ddfip64))
    expect(page).to have_selector("h1", text: "DDFIP des Pyrénées-Atlantiques")
    expect(page).to have_text("15 utilisateurs | Page 1 sur 2")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Maxime Gauthier")
  end

  it "selects and excludes all users through several pages on the office page" do
    # Create a bunch of users to have several pages
    #
    pelp_bayonne.users << create_list(:user, 10, organization: ddfip64)

    visit admin_office_path(pelp_bayonne)

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
      click_on "Tout exclure du guichet"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir exclure les 13 utilisateurs sélectionnés du guichet ?" do
      click_on "Continuer"
    end

    # The browser should stay on the office page
    # No users should appear anymore
    #
    expect(page).to have_current_path(admin_office_path(pelp_bayonne))
    expect(page).to have_selector("h1", text: "PELP de Bayonne")
    expect(page).to have_text("Aucun utilisateur assigné à ce guichet.")

    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to have_no_selector(".datatable__selection")
    expect(page).to have_no_selector("[role=dialog]")
    expect(page).to have_selector("[role=log]", text: "Les utilisateurs sélectionnés ont été exclus du guichet.")

    # The notification doesn't propose to rollback the last action
    #
    within "[role=log]", text: "Les utilisateurs sélectionnés ont été exclus du guichet." do |alert|
      expect(alert).to have_no_button("Cancel")
    end

    click_on "DDFIP des Pyrénées-Atlantiques"

    # The user should remains available on the DDFIP page
    #
    expect(page).to have_current_path(admin_ddfip_path(ddfip64))
    expect(page).to have_selector("h1", text: "DDFIP des Pyrénées-Atlantiques")
    expect(page).to have_text("15 utilisateurs | Page 1 sur 2")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Maxime Gauthier")
  end

  it "discards an user from the office page & rollbacks" do
    visit admin_office_path(pelp_bayonne)

    # A table of users should be present
    # with a button to remove them
    #
    within :table_row, { "Utilisateur" => "Maxime Gauthier" } do
      click_on "Supprimer cet utilisateur"
    end

    # A confirmation dialog should appear
    #
    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer cet utilisateur ?" do
      click_on "Continuer"
    end

    # The browser should stay on the office page
    # The user should not appear anymore
    #
    expect(page).to have_current_path(admin_office_path(pelp_bayonne))
    expect(page).to have_selector("h1", text: "PELP de Bayonne")
    expect(page).to have_no_selector(:table_row, "Utilisateur" => "Maxime Gauthier")

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

    # The browser should stay on the office page
    # The user should not appear anymore
    # The user should be back again
    #
    expect(page).to have_current_path(admin_office_path(pelp_bayonne))
    expect(page).to have_selector("h1", text: "PELP de Bayonne")
    expect(page).to have_selector(:table_row, "Utilisateur" => "Maxime Gauthier")

    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).to have_no_selector("[role=log]", text: "L'utilisateur a été supprimé.")
    expect(page).to have_selector("[role=log]", text: "La suppression de l'utilisateur a été annulée.")
  end
end
