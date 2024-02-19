# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Reports::Confirmations::EditComponent, type: :component do
  it "renders a modal form to confirm an applicable report" do
    report = build_stubbed(:report, :resolved_as_applicable)

    render_inline described_class.new(report)

    expect(page).to have_selector(".modal form") do |form|
      expect(form).to have_html_attribute("action").with_value("/signalements/confirm/#{report.id}")
      expect(form).to have_text("Vous êtes sur le point de transmetre une réponse définitive à la collectivité :")
      expect(form).to have_field("Motif")
      expect(form).to have_field("Observations")
    end
  end

  it "renders a modal form to confirm an inapplicable report" do
    report = build_stubbed(:report, :resolved_as_inapplicable)

    render_inline described_class.new(report)

    expect(page).to have_selector(".modal form") do |form|
      expect(form).to have_html_attribute("action").with_value("/signalements/confirm/#{report.id}")
      expect(form).to have_text("Vous êtes sur le point de transmetre une réponse définitive à la collectivité :")
      expect(form).to have_field("Motif")
      expect(form).to have_field("Observations")
    end
  end
end
