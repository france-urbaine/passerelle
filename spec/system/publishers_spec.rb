# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Publishers", type: :system, use_fixtures: true do
  fixtures :publishers

  it "visits index & show pages" do
    visit publishers_path

    expect(page).to have_selector("h1", text: "Editeurs")
    expect(page).to have_link("Fiscalité & Territoire")

    click_on "Fiscalité & Territoire"

    expect(page).to have_current_path(%r{^/publishers/.{36}})
    expect(page).to have_selector("h1", text: "Fiscalité & Territoire")
  end

  it "creates a publisher" do
    visit publishers_path

    expect(page).to have_link("Ajouter un éditeur")
    expect(page).to have_link("Fiscalité & Territoire")

    click_on "Ajouter un éditeur"

    expect(page).to have_selector("[role=dialog]", text: "Création d'un nouvel éditeur")

    within "[role=dialog]" do
      fill_in  "Nom de l'éditeur",          with: "Mon Territoire"
      fill_in  "Numéro SIREN de l'éditeur", with: "848905758"
      click_on "Enregistrer"
    end

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Un nouvel éditeur a été ajouté avec succés.")

    expect(page).to have_selector("h1", text: "Editeurs")
    expect(page).to have_link("Mon Territoire")
  end

  it "updates a publisher from index page" do
    visit publishers_path

    expect(page).to have_selector("h1", text: "Editeurs")
    expect(page).to have_link("Fiscalité & Territoire")

    within "tr", text: "Fiscalité & Territoire" do
      click_on "Modifier cet éditeur"
    end

    expect(page).to have_selector("[role=dialog]", text: "Modification de l'éditeur")
    expect(page).to have_field("Nom de l'éditeur", with: "Fiscalité & Territoire")

    within "[role=dialog]" do
      fill_in  "Nom de l'éditeur", with: "Mon Territoire"
      click_on "Enregistrer"
    end

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")

    expect(page).to have_selector("h1", text: "Editeurs")
    expect(page).to have_link("Mon Territoire")
  end

  it "updates a publisher from the show page" do
    visit publisher_path(publishers(:fiscalite_territoire))

    expect(page).to have_selector("h1", text: "Fiscalité & Territoire")
    expect(page).to have_link("Modifier")

    click_on "Modifier"

    expect(page).to have_selector("[role=dialog]", text: "Modification de l'éditeur")
    expect(page).to have_field("Nom de l'éditeur", with: "Fiscalité & Territoire")

    within "[role=dialog]" do
      fill_in  "Nom de l'éditeur", with: "Mon Territoire"
      click_on "Enregistrer"
    end

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")

    expect(page).to have_selector("h1", text: "Mon Territoire")
  end

  it "removes a publisher" do
    visit publishers_path

    expect(page).to have_selector("h1", text: "Editeurs")
    expect(page).to have_link("Fiscalité & Territoire")

    within "tr", text: "Fiscalité & Territoire" do
      click_on "Supprimer cet éditeur"
    end

    accept_confirm("Supprimer cet éditeur ?")

    expect(page).to     have_selector("h1", text: "Editeurs")
    expect(page).not_to have_link("Fiscalité & Territoire")

    expect(publishers(:fiscalite_territoire)).to be_discarded
  end
end
