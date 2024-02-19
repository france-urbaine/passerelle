# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Reports::Rejections::EditAllComponent, type: :component do
  before do
    ddfip        = create(:ddfip)
    collectivity = create(:collectivity)

    create_list(:report, 2, :transmitted_to_ddfip, ddfip:, collectivity:)
  end

  it "renders a modal form to reject multiple reports" do
    render_inline described_class.new(Report.all)

    expect(page).to have_selector(".modal form") do |form|
      expect(form).to have_html_attribute("action").with_value("/signalements/reject")
      expect(form).to have_text("Vous êtes sur le point de rejeter les 2 signalements sélectionnés.")
    end
  end
end
