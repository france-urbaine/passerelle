# frozen_string_literal: true

require "system_helper"

RSpec.describe "DDFIP collectivities in admin" do
  fixtures :regions, :departements, :epcis, :communes
  fixtures :publishers, :collectivities, :users
  fixtures :ddfips

  let(:ddfip64)     { ddfips(:pyrenees_atlantiques) }
  let(:pays_basque) { collectivities(:pays_basque) }

  before { sign_in(users(:marc)) }

  it "visits an collectivity page from the DDFIP page" do
    visit ddfip_path(ddfip64)

    # A table of all users should be present
    #
    expect(page).to have_selector("h1", text: "DDFIP des Pyrénées-Atlantiques")
    expect(page).to have_selector(:table_row, "Collectivité" => "CA du Pays Basque")
    expect(page).to have_selector(:table_row, "Collectivité" => "Bayonne")

    click_on "CA du Pays Basque"

    # The browser should visit the office page
    #
    expect(page).to have_current_path(admin_collectivity_path(pays_basque))
    expect(page).to have_selector("h1", text: "CA du Pays Basque")

    go_back

    # The browser should redirect back to the collectivity page
    #
    expect(page).to have_current_path(ddfip_path(ddfip64))
    expect(page).to have_selector("h1", text: "DDFIP des Pyrénées-Atlantiques")
  end

  it "paginate collectivities on the DDFIP page" do
    # Create enough collectivities to have several pages
    #
    10.times do
      create(:collectivity, territory: create(:commune, departement: ddfip64.departement))
    end

    visit ddfip_path(ddfip64)

    expect(page).to     have_text("12 collectivités | Page 1 sur 2")
    expect(page).not_to have_button("Options d'affichage")
  end
end
