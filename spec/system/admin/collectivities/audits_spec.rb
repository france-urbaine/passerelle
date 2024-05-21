# frozen_string_literal: true

require "system_helper"

RSpec.describe "Audit of collectivity in admin" do
  fixtures :regions, :departements, :epcis, :communes
  fixtures :collectivities, :publishers, :ddfips, :users, :audits

  let(:pays_basque) { collectivities(:pays_basque) }

  before { sign_in(users(:marc)) }

  it "visits collectivity & audits pages" do
    visit admin_collectivity_path(pays_basque)

    # The browser should visit the collectivity page
    #
    expect(page).to have_current_path(admin_collectivity_path(pays_basque))
    expect(page).to have_selector("a.button", text: "Voir toute l'activité")

    click_on "Voir toute l'activité"

    # The browser should visit the collectivity audits page
    #
    expect(page).to have_current_path(admin_collectivity_audits_path(pays_basque))
    expect(page).to have_selector("pre.logs")
  end
end
