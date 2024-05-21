# frozen_string_literal: true

require "system_helper"

RSpec.describe "Audit of user in admin" do
  fixtures :regions, :departements, :epcis, :communes
  fixtures :collectivities, :publishers, :ddfips, :users, :audits

  let(:marc) { users(:marc) }

  before { sign_in(users(:marc)) }

  it "visits user & audits pages" do
    visit admin_user_path(marc)

    # The browser should visit the user page
    #
    expect(page).to have_current_path(admin_user_path(marc))
    expect(page).to have_selector("a.button", text: "Voir toute l'activité")

    click_on "Voir toute l'activité"

    # The browser should visit the user audits page
    #
    expect(page).to have_current_path(admin_user_audits_path(marc))
    expect(page).to have_selector("pre.logs")
  end
end
