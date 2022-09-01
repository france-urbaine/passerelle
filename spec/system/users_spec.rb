# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users", type: :system, use_fixtures: true do
  fixtures :publishers, :users

  let(:marc)         { users(:marc) }
  let(:organization) { publishers(:fiscalite_territoire) }

  it "visits index & show pages" do
    visit users_path

    expect(page).to have_selector("h1", text: "Utilisateurs")
    expect(page).to have_link("Marc Debomy")

    click_on "Marc Debomy"

    expect(page).to have_current_path(user_path(marc))
    expect(page).to have_selector("h1", text: "Marc Debomy")
  end

  it "visits links from the show page & comes back" do
    visit user_path(marc)

    expect(page).to have_selector("h1", text: "Marc Debomy")
    expect(page).to have_link("Fiscalité & Territoire")

    click_on "Fiscalité & Territoire"

    expect(page).to have_current_path(publisher_path(organization))

    go_back

    expect(page).to have_current_path(user_path(marc))
  end

  it "invites an user from the index page" do
    visit users_path

    click_on "Ajouter un utilisateur"

    expect(page).to have_selector("[role=dialog]", text: "Invitation d'un nouvel utilisateur")

    within "[role=dialog]" do
      fill_in "Organisation", with: "Fiscalité"
      find("[role=option]", text: "Fiscalité & Territoire").click

      expect(page).to have_field("Organisation",           with: "Fiscalité & Territoire")
      expect(page).to have_field("user_organization_data", type: :hidden, with: { type: "Publisher", id: organization.id }.to_json)

      fill_in "Prénom",       with: "Elliot"
      fill_in "Nom",          with: "Alderson"
      fill_in "Adresse mail", with: "robot@fiscalite-territoire.fr"

      click_on "Enregistrer"
    end

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Un nouvel utilisateur a été ajouté avec succés.")

    expect(page).to have_current_path(users_path)
    expect(page).to have_selector("tr", text: "Elliot Alderson")
  end

  it "updates an user from the index page" do
    visit users_path

    within "tr", text: "Marc Debomy" do
      click_on "Modifier cet utilisateur"
    end

    expect(page).to have_selector("[role=dialog]", text: "Modification de l'utilisateur")

    within "[role=dialog]" do
      expect(page).to have_field("Organisation",           with: "Fiscalité & Territoire")
      expect(page).to have_field("user_organization_data", type: :hidden, with: { type: "Publisher", id: organization.id }.to_json)

      expect(page).to have_field("Prénom",       with: "Marc")
      expect(page).to have_field("Nom",          with: "Debomy")
      expect(page).to have_field("Adresse mail", with: "mdebomy@fiscalite-territoire.fr")

      fill_in  "Prénom", with: "Marc-André"
      click_on "Enregistrer"
    end

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")

    expect(page).to have_current_path(users_path)
    expect(page).to have_selector("tr", text: "Marc-André Debomy")
  end

  it "updates a publisher from the show page" do
    visit user_path(marc)

    click_on "Modifier"

    expect(page).to have_selector("[role=dialog]", text: "Modification de l'utilisateur")

    within "[role=dialog]" do
      expect(page).to have_field("Organisation",           with: "Fiscalité & Territoire")
      expect(page).to have_field("user_organization_data", type: :hidden, with: { type: "Publisher", id: organization.id }.to_json)

      expect(page).to have_field("Prénom",       with: "Marc")
      expect(page).to have_field("Nom",          with: "Debomy")
      expect(page).to have_field("Adresse mail", with: "mdebomy@fiscalite-territoire.fr")

      fill_in  "Prénom", with: "Marc-André"
      click_on "Enregistrer"
    end

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")

    expect(page).to have_current_path(user_path(marc))
    expect(page).to have_selector("h1", text: "Marc-André Debomy")
  end

  it "removes an user from the index page" do
    visit users_path

    within "tr", text: "Marc Debomy" do
      click_on "Supprimer cet utilisateur"
    end

    accept_confirm "Supprimer cet utilisateur ?"

    expect(page).to have_current_path(users_path)
    expect(page).to have_selector("[role=alert]", text: "Le compte de l'utilisateur a été supprimé définitivement.")

    expect(page).not_to have_selector("tr", text: "Marc Debomy")
  end
end
