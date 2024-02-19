# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Reports::Rejections::RemoveComponent, type: :component do
  let(:report) { build_stubbed(:report, :rejected_by_ddfip) }

  it "renders a modal form to undo report rejection" do
    render_inline described_class.new(report)

    expect(page).to have_selector(".modal form") do |form|
      expect(form).to have_html_attribute("action").with_value("/signalements/reject/#{report.id}")
      expect(form).to have_text("Vous êtes sur le point d'annuler le rejet du signalement suivant :")
    end
  end
end
