# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Reports::Index::Component, type: :component do
  let(:collectivity) { create(:collectivity) }
  let(:ddfip)        { create(:ddfip) }
  let(:reports)      { create_list(:report, 2, :ready, :made_for_ddfip, collectivity:, ddfip:) }
  let(:pagy)         { Pagy.new(count: 56, page: 1, limit: 20) }
  let(:transmission) { build(:transmission, collectivity:) }

  it "renders the index to a collectivity user" do
    sign_in_as(organization: collectivity)

    render_inline described_class.new(collectivity.reports, pagy, transmission)

    expect(page).to have_selector("h1", text: "Signalements")
  end
end
