# frozen_string_literal: true

require "system_helper"

RSpec.describe "Audit of DGFIP in admin" do
  fixtures :regions, :departements, :epcis, :communes
  fixtures :collectivities, :publishers, :ddfips, :dgfips, :users, :audits

  let(:dgfip) { dgfips(:dgfip) }

  before { sign_in(users(:marc)) }

  it "visits DGFIP & audits pages" do
    visit admin_dgfip_path(dgfip)

    # The browser should visit the DGFIP page
    #
    expect(page).to have_current_path(admin_dgfip_path(dgfip))
    expect(page).to have_selector("a.button", text: "Voir toute l'activité")

    click_on "Voir toute l'activité"

    # The browser should visit the DGFIP audits page
    #
    expect(page).to have_current_path(admin_dgfip_audits_path(dgfip))
    expect(page).to have_selector("pre.logs")
  end
end
