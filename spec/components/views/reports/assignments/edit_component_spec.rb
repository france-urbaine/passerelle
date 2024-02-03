# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Reports::Assignments::EditComponent, type: :component do
  let!(:ddfip) { create(:ddfip) }

  before { sign_in_as(organization: ddfip) }

  it "renders a form in a modal to assign a report to an office" do
    report = create(:report, :transmitted, ddfip:)

    render_inline described_class.new(report)

    expect(page).to have_selector(".modal form") do |form|
      expect(form).to have_html_attribute("action").with_value("/signalements/assign/#{report.id}")

      expect(form).to have_field("Veuillez sélectionner le guichet auquel sera assigné ce signalement :")
    end
  end
end
