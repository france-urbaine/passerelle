# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Reports::Assignments::FormComponent, type: :component do
  let!(:ddfip) { create(:ddfip) }

  before { sign_in_as(organization: ddfip) }

  it "renders a form in a modal to assign a report to an office" do
    report = create(:report, :transmitted, ddfip:)

    render_inline described_class.new(report)

    expect(page).to have_selector(".modal form") do |form|
      expect(form).to have_html_attribute("action").with_value("/signalements/#{report.id}/assignment")

      expect(form).to have_field("Guichet")
    end
  end
end
