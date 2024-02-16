# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Reports::Assignments::RemoveComponent, type: :component do
  let(:report) { build_stubbed(:report, :assigned_to_office) }

  it "renders a modal form to undo report assignment" do
    render_inline described_class.new(report)

    expect(page).to have_selector(".modal form") do |form|
      expect(form).to have_html_attribute("action").with_value("/signalements/assign/#{report.id}")
      expect(form).to have_text("Vous êtes sur le point d'annuler l'assignation du signalement suivant :")
    end
  end
end
