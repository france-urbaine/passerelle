# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Communes", type: :system, use_fixtures: true do
  fixtures :ddfips, :departements, :regions

  let(:ddifp64)              { ddfips(:pyrenees_atlantiques) }
  let(:pyrenees_atlantiques) { departements(:pyrenees_atlantiques) }
  let(:nouvelle_aquitaine)   { regions(:nouvelle_aquitaine) }

  it "visits index & show pages" do
    visit ddfips_path

    expect(page).to have_selector("h1", text: "DDFIP")
    expect(page).to have_link("DDFIP des Pyrénées-Atlantiques")

    click_on "DDFIP des Pyrénées-Atlantiques"

    expect(page).to have_current_path(ddfip_path(ddifp64))
    expect(page).to have_selector("h1", text: "DDFIP des Pyrénées-Atlantiques")
  end

  it "visits links from the show page & comes back" do
    visit ddfip_path(ddifp64)

    expect(page).to have_selector("h1", text: "DDFIP des Pyrénées-Atlantiques")
    expect(page).to have_link("Pyrénées-Atlantiques")

    click_on "Pyrénées-Atlantiques"

    expect(page).to have_current_path(departement_path(pyrenees_atlantiques))

    go_back

    expect(page).to have_current_path(ddfip_path(ddifp64))
  end

  it "creates a DDFIP from the index page" do
    visit ddfips_path

    click_on "Ajouter une DDFIP"

    expect(page).to have_selector("[role=dialog]", text: "Création d'une nouvelle DDFIP")

    within "[role=dialog]" do
      fill_in  "Nom de la DDFIP", with: "DDFIP de la Gironde"
      fill_in  "Département",     with: "33"

      find("[role=option]", text: "Gironde").click

      click_on "Enregistrer"
    end

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Une nouvelle DDFIP a été ajoutée avec succés.")

    expect(page).to have_current_path(ddfips_path)
    expect(page).to have_selector("tr", text: "DDFIP de la Gironde")
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

    expect(page).to have_current_path(ddfips_path)
    expect(page).to have_selector("tr", text: "DDFIP du 64")
  end

  it "updates a DDFIP from the show page" do
    visit ddfip_path(ddifp64)

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

    expect(page).to have_current_path(ddfip_path(ddifp64))
    expect(page).to have_selector("h1", text: "DDFIP du 64")
  end

  it "removes a DDFIP from the index page" do
    visit ddfips_path

    within "tr", text: "DDFIP des Pyrénées-Atlantiques" do
      click_on "Supprimer cette DDFIP"
    end

    accept_confirm "Supprimer cette DDFIP ?"

    expect(page).to have_current_path(ddfips_path)
    expect(page).to have_selector("[role=alert]", text: "Le compte de la DDFIP a été archivé.")

    expect(page).not_to have_selector("tr", text: "DDFIP des Pyrénées-Atlantiques")
  end
end
