# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Services", type: :system, use_fixtures: true do
  fixtures :ddfips, :services

  let(:ddifp64)            { ddfips(:pyrenees_atlantiques) }
  let(:pelp_bayonne)       { services(:pelp_bayonne) }

  it "visits index & show pages" do
    visit services_path

    expect(page).to have_selector("h1", text: "Guichets")
    expect(page).to have_link("PELP de Bayonne")

    click_on "PELP de Bayonne"

    expect(page).to have_selector("h1", text: "PELP de Bayonne")
    expect(page).to have_current_path(service_path(pelp_bayonne))
  end

  it "visits links from the show page & comes back" do
    visit service_path(pelp_bayonne)

    expect(page).to have_selector("h1", text: "PELP de Bayonne")
    expect(page).to have_link("DDFIP des Pyrénées-Atlantiques")

    click_on "DDFIP des Pyrénées-Atlantiques"

    expect(page).to have_selector("h1", text: "DDFIP des Pyrénées-Atlantiques")
    expect(page).to have_current_path(ddfip_path(ddifp64))

    go_back

    expect(page).to have_selector("h1", text: "PELP de Bayonne")
    expect(page).to have_current_path(service_path(pelp_bayonne))
  end

  it "creates a service from the index page" do
    visit services_path

    click_on "Ajouter un guichet"

    expect(page).to have_selector("[role=dialog]", text: "Création d'un nouveau guichet")

    within "[role=dialog]" do
      fill_in "DDFIP", with: "64"
      find("[role=option]", text: "DDFIP des Pyrénées-Atlantiques").click

      fill_in "Nom du guichet", with: "SIP de Pau"
      select "Occupation de locaux d'habitation", from: "Action"

      click_on "Enregistrer"
    end

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Un nouveau guichet a été ajouté avec succés.")

    expect(page).to have_selector("h1", text: "Guichets")
    expect(page).to have_selector("tr", text: "SIP de Pau")
    expect(page).to have_current_path(services_path)
  end

  it "updates a service from the index page" do
    visit services_path

    within "tr", text: "PELP de Bayonne" do
      click_on "Modifier ce guichet"
    end

    expect(page).to have_selector("[role=dialog]", text: "Modification du guichet")

    within "[role=dialog]" do
      expect(page).to have_field("DDFIP",          with: "DDFIP des Pyrénées-Atlantiques")
      expect(page).to have_field("Nom du guichet", with: "PELP de Bayonne")
      expect(page).to have_select("Action",        selected: "Évaluation de locaux économiques")

      fill_in  "Nom du guichet", with: "PELP de Bayonne-Anglet-Biarritz"
      click_on "Enregistrer"
    end

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")

    expect(page).to have_selector("h1", text: "Guichets")
    expect(page).to have_selector("tr", text: "PELP de Bayonne-Anglet-Biarritz")
    expect(page).to have_current_path(services_path)
  end

  it "updates a service from the show page" do
    visit service_path(pelp_bayonne)

    click_on "Modifier"

    expect(page).to have_selector("[role=dialog]", text: "Modification du guichet")

    within "[role=dialog]" do
      expect(page).to have_field("DDFIP",          with: "DDFIP des Pyrénées-Atlantiques")
      expect(page).to have_field("Nom du guichet", with: "PELP de Bayonne")
      expect(page).to have_select("Action",        selected: "Évaluation de locaux économiques")

      fill_in  "Nom du guichet", with: "PELP de Bayonne-Anglet-Biarritz"
      click_on "Enregistrer"
    end

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")

    expect(page).to have_selector("h1", text: "PELP de Bayonne-Anglet-Biarritz")
    expect(page).to have_current_path(service_path(pelp_bayonne))
  end

  it "removes a DDFIP from the index page" do
    visit services_path

    within "tr", text: "PELP de Bayonne" do
      click_on "Supprimer ce guichet"
    end

    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer ce guichet ?" do
      click_on "Continuer"
    end

    expect(page).to have_selector("[role=alert]", text: "Le guichet a été archivé.")

    expect(page).to     have_selector("h1", text: "Guichets")
    expect(page).not_to have_selector("tr", text: "PELP de Bayonne")
    expect(page).to     have_current_path(services_path)
  end

  it "removes a DDFIP from the show page" do
    visit service_path(pelp_bayonne)

    click_on "Supprimer"

    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer ce guichet ?" do
      click_on "Continuer"
    end

    expect(page).to have_selector("[role=alert]", text: "Le guichet a été archivé.")

    expect(page).to     have_selector("h1", text: "Guichets")
    expect(page).not_to have_selector("tr", text: "PELP de Bayonne")
    expect(page).to     have_current_path(services_path)
  end

  it "removes a selection of publisher from the index page" do
    visit services_path

    within "tr", text: "PELP de Bayonne" do
      find("input[type=checkbox]").check
    end

    within "#index_header", text: "1 guichet sélectionné" do
      click_on "Supprimer la sélection"
    end

    within "[role=dialog]", text: "Êtes-vous sûrs de vouloir supprimer le guichet sélectionné ?" do
      click_on "Continuer"
    end

    expect(page).to have_selector("[role=alert]", text: "Les guichets sélectionnés ont été archivés.")

    expect(page).to     have_selector("h1", text: "Guichets")
    expect(page).not_to have_selector("tr", text: "PELP de Bayonne")
    expect(page).not_to have_selector("#index_header", text: "1 guichet sélectionné")
    expect(page).to     have_current_path(services_path)
  end
end
