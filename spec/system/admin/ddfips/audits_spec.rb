# frozen_string_literal: true

require "system_helper"

RSpec.describe "Audit of DDFIP in admin" do
  fixtures :regions, :departements, :epcis, :communes
  fixtures :collectivities, :publishers, :ddfips, :users, :audits

  let(:ddfip64) { ddfips(:pyrenees_atlantiques) }

  before { sign_in(users(:marc)) }

  it "visits DDFIP & audits pages" do
    visit admin_ddfip_path(ddfip64)

    # The browser should visit the DDFIP page
    #
    expect(page).to have_current_path(admin_ddfip_path(ddfip64))
    expect(page).to have_selector("a.button", text: "Voir toute l'activité")

    click_on "Voir toute l'activité"

    # The browser should visit the DDFIP audits page
    #
    expect(page).to have_current_path(admin_ddfip_audits_path(ddfip64))
    expect(page).to have_selector("pre.logs")
  end
end
