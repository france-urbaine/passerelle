# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Publishers", use_fixtures: true do
  fixtures :publishers, :collectivities

  let(:fiscalite_territoire) { publishers(:fiscalite_territoire) }
  let(:pays_basque)          { collectivities(:pays_basque) }

  it "visits index & show pages" do
    visit publishers_path

    expect(page).to have_selector("h1", text: "Editeurs")
    expect(page).to have_link("Fiscalité & Territoire")

    click_on "Fiscalité & Territoire"

    expect(page).to have_selector("h1", text: "Fiscalité & Territoire")
    expect(page).to have_current_path(publisher_path(fiscalite_territoire))
  end

  it "visits links from the show page & comes back" do
    visit publisher_path(fiscalite_territoire)

    expect(page).to have_selector("h1", text: "Fiscalité & Territoire")
    expect(page).to have_link("CA du Pays Basque")
    expect(page).to have_link("Bayonne")

    click_on "CA du Pays Basque"

    expect(page).to have_selector("h1", text: "CA du Pays Basque")
    expect(page).to have_current_path(collectivity_path(pays_basque))

    go_back

    expect(page).to have_selector("h1", text: "Fiscalité & Territoire")
    expect(page).to have_current_path(publisher_path(fiscalite_territoire))
  end

  it "creates a publisher from the index page" do
    visit publishers_path

    click_on "Ajouter un éditeur"

    expect(page).to have_selector("[role=dialog]", text: "Création d'un nouvel éditeur")

    within "[role=dialog]" do
      fill_in  "Nom de l'éditeur",          with: "Mon Territoire"
      fill_in  "Numéro SIREN de l'éditeur", with: "848905758"
      click_on "Enregistrer"
    end

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Un nouvel éditeur a été ajouté avec succés.")

    expect(page).to have_selector("h1", text: "Mon Territoire")
    expect(page).to have_current_path(publisher_path(Publisher.last))
  end

  it "updates a publisher from the index page" do
    visit publishers_path

    within "tr", text: "Fiscalité & Territoire" do
      click_on "Modifier cet éditeur"
    end

    expect(page).to have_selector("[role=dialog]", text: "Modification de l'éditeur")

    within "[role=dialog]" do
      expect(page).to have_field("Nom de l'éditeur",          with: "Fiscalité & Territoire")
      expect(page).to have_field("Numéro SIREN de l'éditeur", with: "511022394")

      fill_in  "Nom de l'éditeur", with: "Mon Territoire"
      click_on "Enregistrer"
    end

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")

    expect(page).to have_selector("h1", text: "Editeurs")
    expect(page).to have_selector("tr", text: "Mon Territoire")
    expect(page).to have_current_path(publishers_path)
  end

  it "updates a publisher from the show page" do
    visit publisher_path(fiscalite_territoire)

    click_on "Modifier"

    expect(page).to have_selector("[role=dialog]", text: "Modification de l'éditeur")

    within "[role=dialog]" do
      expect(page).to have_field("Nom de l'éditeur", with: "Fiscalité & Territoire")
      expect(page).to have_field("Numéro SIREN de l'éditeur", with: "511022394")

      fill_in  "Nom de l'éditeur", with: "Mon Territoire"
      click_on "Enregistrer"
    end

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")

    expect(page).to have_selector("h1", text: "Mon Territoire")
    expect(page).to have_current_path(publisher_path(fiscalite_territoire))
  end

  it "removes a publisher from the index page" do
    visit publishers_path

    within "tr", text: "Fiscalité & Territoire" do
      click_on "Supprimer cet éditeur"
    end

    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer ce compte ?" do
      click_on "Continuer"
    end

    expect(page).to have_selector("[role=alert]", text: "Le compte de l'éditeur a été archivé.")

    expect(page).to     have_selector("h1", text: "Editeurs")
    expect(page).not_to have_selector("tr", text: "Fiscalité & Territoire")
    expect(page).to     have_current_path(publishers_path)
  end

  it "removes a publisher from the show page" do
    visit publisher_path(fiscalite_territoire)

    click_on "Supprimer"

    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer ce compte ?" do
      click_on "Continuer"
    end

    expect(page).to have_selector("[role=alert]", text: "Le compte de l'éditeur a été archivé.")

    expect(page).to     have_selector("h1", text: "Editeurs")
    expect(page).not_to have_selector("tr", text: "Fiscalité & Territoire")
    expect(page).to     have_current_path(publishers_path)
  end

  it "removes a selection of publisher from the index page" do
    visit publishers_path

    within "tr", text: "Fiscalité & Territoire" do
      find("input[type=checkbox]").check
    end

    within "#index_header", text: "1 éditeur sélectionné" do
      click_on "Supprimer la sélection"
    end

    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer l'éditeur sélectionné ?" do
      click_on "Continuer"
    end

    expect(page).to have_selector("[role=alert]", text: "Les comptes des éditeurs sélectionnés ont été archivés.")

    expect(page).to     have_selector("h1", text: "Editeurs")
    expect(page).not_to have_selector("tr", text: "Fiscalité & Territoire")
    expect(page).not_to have_selector("#index_header", text: "1 éditeur sélectionné")
    expect(page).to     have_current_path(publishers_path)
  end
end
