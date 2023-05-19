# frozen_string_literal: true

require "system_helper"

RSpec.describe "Collectivity offices" do
  fixtures :regions, :departements, :epcis, :communes
  fixtures :publishers, :collectivities, :users
  fixtures :ddfips, :offices, :office_communes

  let(:pays_basque)  { collectivities(:pays_basque) }
  let(:pelp_bayonne) { offices(:pelp_bayonne) }
  let(:bayonne)      { communes(:bayonne) }

  before { sign_in(users(:marc)) }

  it "visits an office page from the collectivity page" do
    visit collectivity_path(pays_basque)

    # A table of all users should be present
    #
    expect(page).to have_selector("h1", text: "CA du Pays Basque")
    expect(page).to have_selector(:table_row, "Guichet" => "PELP de Bayonne")
    expect(page).to have_selector(:table_row, "Guichet" => "SIP de Bayonne")

    click_on "PELP de Bayonne"

    # The browser should visit the office page
    #
    expect(page).to have_current_path(office_path(pelp_bayonne))
    expect(page).to have_selector("h1", text: "PELP de Bayonne")

    go_back

    # The browser should redirect back to the collectivity page
    #
    expect(page).to have_current_path(collectivity_path(pays_basque))
    expect(page).to have_selector("h1", text: "CA du Pays Basque")
  end

  it "paginate offices on the collectivity page" do
    # Create enough offices to have several pages
    #
    create_list(:office, 10, communes: [bayonne])

    visit collectivity_path(pays_basque)

    expect(page).to     have_text("12 guichets | Page 1 sur 2")
    expect(page).not_to have_button("Options d'affichage")
  end
end
