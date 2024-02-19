# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Reports::Rejections::EditComponent, type: :component do
  let(:report) { build_stubbed(:report, :transmitted_to_ddfip) }

  it "renders a modal form to reject a report" do
    render_inline described_class.new(report)

    expect(page).to have_selector(".modal form") do |form|
      expect(form).to have_html_attribute("action").with_value("/signalements/reject/#{report.id}")
      expect(form).to have_text("Vous êtes sur le point de rejeter le signalement suivant :")
      expect(form).to have_field("Observations :")
    end
  end
end
