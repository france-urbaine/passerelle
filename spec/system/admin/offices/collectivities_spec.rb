# frozen_string_literal: true

require "system_helper"

RSpec.describe "Office collectivities in admin" do
  fixtures :regions, :departements, :epcis, :communes
  fixtures :publishers, :collectivities, :users
  fixtures :ddfips, :offices, :office_communes

  let(:pelp_bayonne) { offices(:pelp_bayonne) }
  let(:pays_basque)  { collectivities(:pays_basque) }

  before { sign_in(users(:marc)) }

  it "visits an collectivity page from the office page" do
    visit admin_office_path(pelp_bayonne)

    # A table of all users should be present
    #
    expect(page).to have_selector("h1", text: "PELP de Bayonne")
    expect(page).to have_selector(:table_row, "Collectivité" => "CA du Pays Basque")
    expect(page).to have_selector(:table_row, "Collectivité" => "Bayonne")

    within :table_row, { "Collectivité" => "CA du Pays Basque" } do
      click_on "CA du Pays Basque"
    end

    # The browser should visit the office page
    #
    expect(page).to have_current_path(admin_collectivity_path(pays_basque))
    expect(page).to have_selector("h1", text: "CA du Pays Basque")

    go_back

    # The browser should redirect back to the collectivity page
    #
    expect(page).to have_current_path(admin_office_path(pelp_bayonne))
    expect(page).to have_selector("h1", text: "PELP de Bayonne")
  end

  it "paginate collectivities on the DDFIP page" do
    # Create enough collectivities to have several pages
    #
    10.times do
      commune = create(:commune, departement: pelp_bayonne.departement)
      pelp_bayonne.communes << commune
      create(:collectivity, territory: commune)
    end

    visit admin_office_path(pelp_bayonne)

    expect(page).to have_text("12 collectivités | Page 1 sur 2")
    expect(page).to have_no_button("Options d'affichage")
  end
end
