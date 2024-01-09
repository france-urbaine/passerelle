# frozen_string_literal: true

require "system_helper"

RSpec.describe "Office collectivities in organization" do
  fixtures :regions, :departements, :epcis, :communes
  fixtures :publishers, :collectivities, :users
  fixtures :ddfips, :offices, :office_communes

  let(:pelp_bayonne) { offices(:pelp_bayonne) }
  let(:pays_basque)  { collectivities(:pays_basque) }

  before { sign_in(users(:maxime)) }

  it "visits an collectivity page from the office page" do
    visit organization_office_path(pelp_bayonne)

    # A table of all collectivites should be present
    #
    expect(page).to have_selector("h1", text: "PELP de Bayonne")
    expect(page).to have_selector(:table_row, "Collectivité" => "CA du Pays Basque") do |row|
      expect(row).to have_link("CA du Pays Basque")
    end

    expect(page).to have_selector(:table_row, "Collectivité" => "Bayonne") do |row|
      expect(row).to have_link("Bayonne")
    end
  end

  it "paginate collectivities on the DDFIP page" do
    # Create enough collectivities to have several pages
    #
    10.times do
      commune = create(:commune, departement: pelp_bayonne.departement)
      pelp_bayonne.communes << commune
      create(:collectivity, territory: commune)
    end

    visit organization_office_path(pelp_bayonne)

    expect(page).to have_text("12 collectivités | Page 1 sur 2")
    expect(page).to have_no_button("Options d'affichage")
  end
end
