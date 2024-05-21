# frozen_string_literal: true

require "system_helper"

RSpec.describe "Audit of office in admin" do
  fixtures :regions, :departements, :epcis, :communes
  fixtures :collectivities, :publishers, :ddfips, :offices, :users, :audits

  let(:pelp_bayonne) { offices(:pelp_bayonne) }

  before { sign_in(users(:marc)) }

  it "visits office & audits pages" do
    visit admin_office_path(pelp_bayonne)

    # The browser should visit the office page
    #
    expect(page).to have_current_path(admin_office_path(pelp_bayonne))
    expect(page).to have_selector("a.button", text: "Voir toute l'activité")

    click_on "Voir toute l'activité"

    # The browser should visit the office audits page
    #
    expect(page).to have_current_path(admin_office_audits_path(pelp_bayonne))
    expect(page).to have_selector("pre.logs")
  end
end
