# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Reports::Assignments::EditAllComponent, type: :component do
  before do
    ddfip        = create(:ddfip)
    collectivity = create(:collectivity)

    create_list(:report, 2, :accepted_by_ddfip, ddfip:, collectivity:)
  end

  it "renders a modal form to assign multiple reports" do
    render_inline described_class.new(Report.all)

    expect(page).to have_selector(".modal form") do |form|
      expect(form).to have_html_attribute("action").with_value("/signalements/assign")
      expect(form).to have_text("Vous êtes sur le point d'assigner les 2 signalements sélectionnés à un guichet.")
    end
  end
end
