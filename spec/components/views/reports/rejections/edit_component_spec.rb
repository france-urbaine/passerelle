# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Reports::Rejections::EditComponent, type: :component do
  let(:ddfip)  { create(:ddfip) }
  let(:report) { create(:report, :transmitted, ddfip:) }

  before { sign_in_as(:ddfip) }

  it "renders a modal form to reject a report" do
    render_inline described_class.new(report)

    expect(page).to have_selector(".modal form") do |form|
      expect(form).to have_html_attribute("action").with_value("/signalements/reject/#{report.id}")
      expect(form).to have_text("Vous êtes sur le point de rejeter le signalement suivant")
      expect(form).to have_field("Vous pouvez transmettre des observations à la collectivité :")
    end
  end
end
