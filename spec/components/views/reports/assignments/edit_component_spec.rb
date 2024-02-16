# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Reports::Assignments::EditComponent, type: :component do
  let(:report) { build_stubbed(:report, :accepted_by_ddfip) }

  it "renders a modal form to assign a report to an office" do
    render_inline described_class.new(report)

    expect(page).to have_selector(".modal form") do |form|
      expect(form).to have_html_attribute("action").with_value("/signalements/assign/#{report.id}")
      expect(form).to have_text("Vous êtes sur le point d'assigner le signalement suivant à un guichet :")
      expect(form).to have_field("Veuillez sélectionner un guichet :")
    end
  end
end
