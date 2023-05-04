# frozen_string_literal: true

require "system_helper"

RSpec.describe "Users" do
  fixtures :publishers, :users

  let(:fiscalite_territoire) { publishers(:fiscalite_territoire) }
  let(:marc)                 { users(:marc) }

  it "visits index & show pages" do
    visit users_path

    expect(page).to have_selector("h1", text: "Utilisateurs")
    expect(page).to have_link("Marc Debomy")

    click_on "Marc Debomy"

    expect(page).to have_selector("h1", text: "Marc Debomy")
    expect(page).to have_current_path(user_path(marc))
  end

  it "visits links from the show page & comes back" do
    visit user_path(marc)

    expect(page).to have_selector("h1", text: "Marc Debomy")
    expect(page).to have_link("Fiscalité & Territoire")

    click_on "Fiscalité & Territoire"

    expect(page).to have_selector("h1", text: "Fiscalité & Territoire")
    expect(page).to have_current_path(publisher_path(fiscalite_territoire))

    go_back

    expect(page).to have_selector("h1", text: "Marc Debomy")
    expect(page).to have_current_path(user_path(marc))
  end

  it "invites an user from the index page" do
    visit users_path

    # A button should be present to add a new user
    #
    expect(page).to have_link("Inviter un utilisateur", class: "button")

    click_on "Inviter un utilisateur"

    # A dialog box should appears with a form to fill
    #
    expect(page).to have_selector("[role=dialog]", text: "Invitation d'un nouvel utilisateur")

    within "[role=dialog]" do
      fill_in "Organisation", with: "Fiscalité"

      find("[role=option]", text: "Fiscalité & Territoire").click

      expect(page).to have_field("Organisation",           with: "Fiscalité & Territoire")
      expect(page).to have_field("user_organization_data", type: :hidden, with: {
        type: "Publisher",
        id:   fiscalite_territoire.id
      }.to_json)

      fill_in "Prénom",       with: "Elliot"
      fill_in "Nom",          with: "Alderson"
      fill_in "Adresse mail", with: "robot@fiscalite-territoire.fr"

      click_on "Enregistrer"
    end

    # The browser should stay on index page
    # The new user should appears
    #
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to     have_current_path(users_path)
    expect(page).to     have_selector("h1", text: "Utilisateurs")
    expect(page).to     have_selector("tr", text: "Elliot Alderson")

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Un nouvel utilisateur a été ajouté avec succés.")
  end

  it "updates an user from the index page" do
    visit users_path

    # A button should be present to edit the user
    #
    within "tr", text: "Marc Debomy" do |row|
      expect(row).to have_link("Modifier cet utilisateur", class: "icon-button")

      click_on "Modifier cet utilisateur"
    end

    # A dialog box should appears with a form
    # The form should be filled with user data
    #
    expect(page).to have_selector("[role=dialog]", text: "Modification de l'utilisateur")

    within "[role=dialog]" do
      expect(page).to have_field("Organisation",           with: "Fiscalité & Territoire")
      expect(page).to have_field("user_organization_data", type: :hidden, with: {
        type: "Publisher",
        id:   fiscalite_territoire.id
      }.to_json)

      expect(page).to have_field("Prénom",       with: "Marc")
      expect(page).to have_field("Nom",          with: "Debomy")
      expect(page).to have_field("Adresse mail", with: "mdebomy@fiscalite-territoire.fr")

      fill_in "Prénom", with: "Marc-André"

      click_on "Enregistrer"
    end

    # The browser should stay on index page
    # The user should have changed its name
    #
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to     have_current_path(users_path)
    expect(page).to     have_selector("h1", text: "Utilisateurs")
    expect(page).to     have_selector("tr", text: "Marc-André Debomy")

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "updates an user from the show page" do
    visit user_path(marc)

    # A button should be present to edit the user
    #
    within ".header-bar" do |header|
      expect(header).to have_selector("h1", text: "Marc Debomy")
      expect(header).to have_link("Modifier", class: "button")

      click_on "Modifier"
    end

    # A dialog box should appears with a form
    # The form should be filled with user data
    #
    expect(page).to have_selector("[role=dialog]", text: "Modification de l'utilisateur")

    within "[role=dialog]" do
      expect(page).to have_field("Organisation",           with: "Fiscalité & Territoire")
      expect(page).to have_field("user_organization_data", type: :hidden, with: {
        type: "Publisher",
        id:   fiscalite_territoire.id
      }.to_json)

      expect(page).to have_field("Prénom",       with: "Marc")
      expect(page).to have_field("Nom",          with: "Debomy")
      expect(page).to have_field("Adresse mail", with: "mdebomy@fiscalite-territoire.fr")

      fill_in "Prénom", with: "Marc-André"

      click_on "Enregistrer"
    end

    # The browser should stay on index page
    # The user should have changed its name
    #
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to     have_current_path(user_path(marc))
    expect(page).to     have_selector("h1", text: "Marc-André Debomy")

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")
  end

  it "removes an user from the index page and then rollback" do
    visit users_path

    # A button should be present to remove th user
    #
    within "tr", text: "Marc Debomy" do |row|
      expect(row).to have_link("Supprimer cet utilisateur", class: "icon-button")

      click_on "Supprimer cet utilisateur"
    end

    # A confirmation dialog should appears
    #
    expect(page).to have_selector("[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer cet utilisateur ?")

    within "[role=dialog]" do |dialog|
      expect(dialog).to have_button("Continuer")

      click_on "Continuer"
    end

    # The browser should stay on index page
    # The user should not appears anymore
    #
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to     have_current_path(users_path)
    expect(page).to     have_selector("h1", text: "Utilisateurs")
    expect(page).not_to have_selector("tr", text: "Marc Debomy")

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "L'utilisateur a été supprimé.")

    # The notification should include a button to cancel the last action
    #
    within "[role=alert]", text: "L'utilisateur a été supprimé." do |alert|
      expect(alert).to have_button("Annuler")

      click_on "Annuler"
    end

    # The browser should stay on index page
    # The user should be back again
    #
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).to     have_current_path(users_path)
    expect(page).to     have_selector("h1", text: "Utilisateurs")
    expect(page).to     have_selector("tr", text: "Marc Debomy")

    expect(page).not_to have_selector("[role=alert]", text: "L'utilisateur a été supprimé.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression de l'utilisateur a été annulée.")
  end

  it "removes an user from the show page and then rollback" do
    visit user_path(marc)

    # A button should be present to remove this user
    #
    within ".header-bar" do |header|
      expect(header).to have_selector("h1", text: "Marc Debomy")
      expect(header).to have_link("Supprimer", class: "button")

      click_on "Supprimer"
    end

    # A confirmation dialog should appears
    #
    expect(page).to have_selector("[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer cet utilisateur ?")

    within "[role=dialog]" do |dialog|
      expect(dialog).to have_button("Continuer")

      click_on "Continuer"
    end

    # The browser should stay on index page
    # The user should not appears anymore
    #
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to     have_current_path(users_path)
    expect(page).to     have_selector("h1", text: "Utilisateurs")
    expect(page).not_to have_selector("tr", text: "Marc Debomy")

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "L'utilisateur a été supprimé.")

    # The notification should include a button to cancel the last action
    #
    within "[role=alert]", text: "L'utilisateur a été supprimé." do |alert|
      expect(alert).to have_button("Annuler")

      click_on "Annuler"
    end

    # The browser should stay on index page
    # The user should be back again
    #
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).to     have_current_path(users_path)
    expect(page).to     have_selector("h1", text: "Utilisateurs")
    expect(page).to     have_selector("tr", text: "Marc Debomy")

    expect(page).not_to have_selector("[role=alert]", text: "L'utilisateur a été supprimé.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression de l'utilisateur a été annulée.")
  end

  it "removes a selection of users from the index page and then rollback" do
    visit users_path

    # Some checkboxes should be present to select users
    #
    within "tr", text: "Marc Debomy" do
      find("input[type=checkbox]").check
    end

    # A message should diplay the number of selected users
    # with a button to remove them
    #
    within "#datatable-users-selection-bar" do |header|
      expect(header).to have_text("1 utilisateur sélectionné")
      expect(header).to have_link("Supprimer la sélection", class: "button")

      click_on "Supprimer la sélection"
    end

    # A confirmation dialog should appears
    #
    expect(page).to have_selector("[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer l'utilisateur sélectionné ?")

    within "[role=dialog]" do |dialog|
      expect(dialog).to have_button("Continuer")

      click_on "Continuer"
    end

    # The browser should stay on index page
    # The selected users should not appears anymore
    #
    # The dialog should be closed
    # A notification should be displayed
    #
    expect(page).to     have_current_path(users_path)
    expect(page).to     have_selector("h1", text: "Utilisateurs")
    expect(page).not_to have_selector("tr", text: "Marc Debomy")

    expect(page).not_to have_selector("#datatable-users-selection-bar", text: "1 utilisateur sélectionné")
    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les utilisateurs sélectionnés ont été supprimés.")

    # The notification should include a button to cancel the last action
    #
    within "[role=alert]", text: "Les utilisateurs sélectionnés ont été supprimés." do |alert|
      expect(alert).to have_button("Annuler")

      click_on "Annuler"
    end

    # The browser should stay on index page
    # The remove users should be back again
    #
    # The selection message should not appears again
    # The previous notification should be closed
    # A new notification should be displayed
    #
    expect(page).to     have_current_path(users_path)
    expect(page).to     have_selector("h1", text: "Utilisateurs")
    expect(page).to     have_selector("tr", text: "Marc Debomy")

    expect(page).not_to have_selector("#datatable-users-selection-bar", text: "1 utilisateur sélectionné")
    expect(page).not_to have_selector("[role=alert]", text: "Les utilisateurs sélectionnés ont été supprimés.")
    expect(page).to     have_selector("[role=alert]", text: "La suppression des utilisateurs sélectionnés a été annulée.")
  end
end
