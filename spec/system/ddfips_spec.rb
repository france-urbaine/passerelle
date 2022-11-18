# frozen_string_literal: true

require "rails_helper"

RSpec.describe "DDFIPs", use_fixtures: true do
  fixtures :ddfips, :departements, :regions, :services

  let(:ddfip64)              { ddfips(:pyrenees_atlantiques) }
  let(:pyrenees_atlantiques) { departements(:pyrenees_atlantiques) }
  let(:nouvelle_aquitaine)   { regions(:nouvelle_aquitaine) }
  let(:pelp_bayonne)         { services(:pelp_bayonne) }

  it "visits index & show pages" do
    visit ddfips_path

    expect(page).to have_selector("h1", text: "DDFIP")
    expect(page).to have_link("DDFIP des Pyrénées-Atlantiques")

    click_on "DDFIP des Pyrénées-Atlantiques"

    expect(page).to have_selector("h1", text: "DDFIP des Pyrénées-Atlantiques")
    expect(page).to have_current_path(ddfip_path(ddfip64))
  end

  it "visits links from the show page & comes back" do
    visit ddfip_path(ddfip64)

    expect(page).to have_selector("h1", text: "DDFIP des Pyrénées-Atlantiques")
    expect(page).to have_link("Pyrénées-Atlantiques")
    expect(page).to have_link("PELP de Bayonne")

    click_on "Pyrénées-Atlantiques"

    expect(page).to have_selector("h1", text: "Pyrénées-Atlantiques")
    expect(page).to have_current_path(departement_path(pyrenees_atlantiques))

    go_back

    expect(page).to have_selector("h1", text: "DDFIP des Pyrénées-Atlantiques")
    expect(page).to have_current_path(ddfip_path(ddfip64))

    click_on "PELP de Bayonne"

    expect(page).to have_selector("h1", text: "PELP de Bayonne")
    expect(page).to have_current_path(service_path(pelp_bayonne))

    go_back

    expect(page).to have_selector("h1", text: "DDFIP des Pyrénées-Atlantiques")
    expect(page).to have_current_path(ddfip_path(ddfip64))
  end

  it "creates a DDFIP from the index page" do
    visit ddfips_path

    click_on "Ajouter une DDFIP"

    expect(page).to have_selector("[role=dialog]", text: "Création d'une nouvelle DDFIP")

    within "[role=dialog]" do
      fill_in "Nom de la DDFIP", with: "DDFIP de la Gironde"
      fill_in "Département",     with: "33"

      find("[role=option]", text: "Gironde").click

      click_on "Enregistrer"
    end

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Une nouvelle DDFIP a été ajoutée avec succés.")

    expect(page).to have_selector("h1", text: "DDFIP de la Gironde")
    expect(page).to have_current_path(ddfip_path(DDFIP.last))
  end

  it "updates a DDFIP from the index page" do
    visit ddfips_path

    within "tr", text: "DDFIP des Pyrénées-Atlantiques" do
      click_on "Modifier cette DDFIP"
    end

    expect(page).to have_selector("[role=dialog]", text: "Modification de la DDFIP")

    within "[role=dialog]" do
      expect(page).to have_field("Nom de la DDFIP", with: "DDFIP des Pyrénées-Atlantiques")
      expect(page).to have_field("Département",     with: "Pyrénées-Atlantiques")

      fill_in  "Nom de la DDFIP", with: "DDFIP du 64"
      click_on "Enregistrer"
    end

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")

    expect(page).to have_selector("h1", text: "DDFIP")
    expect(page).to have_selector("tr", text: "DDFIP du 64")
    expect(page).to have_current_path(ddfips_path)
  end

  it "updates a DDFIP from the show page" do
    visit ddfip_path(ddfip64)

    click_on "Modifier"

    expect(page).to have_selector("[role=dialog]", text: "Modification de la DDFIP")

    within "[role=dialog]" do
      expect(page).to have_field("Nom de la DDFIP", with: "DDFIP des Pyrénées-Atlantiques")
      expect(page).to have_field("Département",     with: "Pyrénées-Atlantiques")

      fill_in  "Nom de la DDFIP", with: "DDFIP du 64"
      click_on "Enregistrer"
    end

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")

    expect(page).to have_selector("h1", text: "DDFIP du 64")
    expect(page).to have_current_path(ddfip_path(ddfip64))
  end

  it "removes a DDFIP from the index page" do
    visit ddfips_path

    within "tr", text: "DDFIP des Pyrénées-Atlantiques" do
      click_on "Supprimer cette DDFIP"
    end

    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer ce compte ?" do
      click_on "Continuer"
    end

    expect(page).to have_selector("[role=alert]", text: "Le compte de la DDFIP a été archivé.")

    expect(page).to     have_selector("h1", text: "DDFIP")
    expect(page).not_to have_selector("tr", text: "DDFIP des Pyrénées-Atlantiques")
    expect(page).to     have_current_path(ddfips_path)
  end

  it "removes a DDFIP from the show page" do
    visit ddfip_path(ddfip64)

    click_on "Supprimer"

    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer ce compte ?" do
      click_on "Continuer"
    end

    expect(page).to have_selector("[role=alert]", text: "Le compte de la DDFIP a été archivé.")

    expect(page).to     have_selector("h1", text: "DDFIP")
    expect(page).not_to have_selector("tr", text: "DDFIP des Pyrénées-Atlantiques")
    expect(page).to     have_current_path(ddfips_path)
  end

  it "removes a selection of publisher from the index page" do
    visit ddfips_path

    within "tr", text: "DDFIP des Pyrénées-Atlantiques" do
      find("input[type=checkbox]").check
    end

    within "#index_header", text: "1 DDFIP sélectionnée" do
      click_on "Supprimer la sélection"
    end

    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer la DDFIP sélectionnée ?" do
      click_on "Continuer"
    end

    expect(page).to have_selector("[role=alert]", text: "Les comptes des DDFIP sélectionnées ont été archivés.")

    expect(page).to     have_selector("h1", text: "DDFIP")
    expect(page).not_to have_selector("tr", text: "DDFIP des Pyrénées-Atlantiques")
    expect(page).not_to have_selector("#index_header", text: "1 DDFIP sélectionnée")
    expect(page).to     have_current_path(ddfips_path)
  end
end
