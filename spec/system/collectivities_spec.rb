# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Collectivities", type: :system, use_fixtures: true do
  fixtures :collectivities, :publishers, :epcis, :ddfips

  let(:pays_basque) { collectivities(:pays_basque) }
  let(:publisher)   { publishers(:fiscalite_territoire) }
  let(:territoire)  { epcis(:pays_basque) }
  let(:ddfip)       { ddfips(:pyrenees_atlantiques) }

  it "visits index & show pages" do
    visit collectivities_path

    expect(page).to have_selector("h1", text: "Collectivités")
    expect(page).to have_link("CA du Pays Basque")
    expect(page).to have_link("Métropole Européenne de Lille")

    click_on "CA du Pays Basque"

    expect(page).to have_current_path(collectivity_path(pays_basque, back: collectivities_path))
    expect(page).to have_selector("h1", text: "CA du Pays Basque")
  end

  it "visits links from the show page & comes back" do
    visit collectivity_path(pays_basque)

    expect(page).to have_selector("h1", text: "CA du Pays Basque")
    expect(page).to have_link("Fiscalité & Territoire")
    expect(page).to have_link("CA du Pays Basque")

    click_on "Fiscalité & Territoire"

    expect(page).to have_current_path(publisher_path(publisher))

    go_back
    click_on "CA du Pays Basque"

    expect(page).to have_current_path(epci_path(territoire))

    go_back

    expect(page).to have_current_path(collectivity_path(pays_basque))
  end

  it "creates a collectivity from the index page" do
    visit collectivities_path

    click_on "Ajouter une collectivité"

    expect(page).to have_selector("[role=dialog]", text: "Création d'une nouvelle collectivité")

    within "[role=dialog]" do
      select "Fiscalité & Territoire", from: "Editeur"
      select "EPCI",                   from: "Type de territoire"

      fill_in "ID du territoire",                with: epcis(:metropole_aix_marseille).id
      fill_in "Nom de la collectivité",          with: epcis(:metropole_aix_marseille).name
      fill_in "Numéro SIREN de la collectivité", with: epcis(:metropole_aix_marseille).siren

      click_on "Enregistrer"
    end

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Une nouvelle collectivité a été ajoutée avec succés.")

    expect(page).to have_current_path(collectivities_path)
    expect(page).to have_selector("tr", text: "Métropole d'Aix-Marseille-Provence")
  end

  it "updates a collectivity from the index page" do
    visit collectivities_path

    within "tr", text: "CA du Pays Basque" do
      click_on "Modifier cette collectivité"
    end

    expect(page).to have_selector("[role=dialog]", text: "Modification de la collectivité")

    within "[role=dialog]" do
      expect(page).to have_select("Editeur",            selected: "Fiscalité & Territoire")
      expect(page).to have_select("Type de territoire", selected: "EPCI")
      expect(page).to have_field("ID du territoire",                with: epcis(:pays_basque).id)
      expect(page).to have_field("Nom de la collectivité",          with: "CA du Pays Basque")
      expect(page).to have_field("Numéro SIREN de la collectivité", with: "200067106")

      fill_in  "Nom de la collectivité", with: "Agglomération du Pays Basque"
      click_on "Enregistrer"
    end

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")

    expect(page).to have_current_path(collectivities_path)
    expect(page).to have_selector("tr", text: "Agglomération du Pays Basque")
  end

  it "updates a collectivity from the show page" do
    visit collectivity_path(pays_basque)

    click_on "Modifier"

    expect(page).to have_selector("[role=dialog]", text: "Modification de la collectivité")

    within "[role=dialog]" do
      expect(page).to have_select("Editeur",            selected: "Fiscalité & Territoire")
      expect(page).to have_select("Type de territoire", selected: "EPCI")
      expect(page).to have_field("ID du territoire",                with: epcis(:pays_basque).id)
      expect(page).to have_field("Nom de la collectivité",          with: "CA du Pays Basque")
      expect(page).to have_field("Numéro SIREN de la collectivité", with: "200067106")

      fill_in  "Nom de la collectivité", with: "Agglomération du Pays Basque"
      click_on "Enregistrer"
    end

    expect(page).not_to have_selector("[role=dialog]")
    expect(page).to     have_selector("[role=alert]", text: "Les modifications ont été enregistrées avec succés.")

    expect(page).to have_current_path(collectivity_path(pays_basque))
    expect(page).to have_selector("h1", text: "Agglomération du Pays Basque")
  end

  it "removes a collectivity from the index page" do
    visit collectivities_path

    within "tr", text: "CA du Pays Basque" do
      click_on "Supprimer cette collectivité"
    end

    accept_confirm "Supprimer cette collectivité ?"

    expect(page).to have_current_path(collectivities_path)
    expect(page).to have_selector("[role=alert]", text: "Le compte de la collectivité a été archivé.")

    expect(page).not_to have_selector("tr", text: "CA du Pays Basque")
  end
end
