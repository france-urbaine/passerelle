# frozen_string_literal: true

require "system_helper"

RSpec.describe "Audit of publisher in admin" do
  fixtures :regions, :departements, :epcis, :communes
  fixtures :collectivities, :publishers, :ddfips, :users, :audits

  let(:solutions_territoire) { publishers(:solutions_territoire) }

  before { sign_in(users(:marc)) }

  it "visits publisher & audits pages" do
    visit admin_publisher_path(solutions_territoire)

    # The browser should visit the publisher page
    #
    expect(page).to have_current_path(admin_publisher_path(solutions_territoire))
    expect(page).to have_selector("a.button", text: "Voir toute l'activité")

    click_on "Voir toute l'activité"

    # The browser should visit the publisher audits page
    #
    expect(page).to have_current_path(admin_publisher_audits_path(solutions_territoire))
    expect(page).to have_selector("pre.logs")
  end
end
