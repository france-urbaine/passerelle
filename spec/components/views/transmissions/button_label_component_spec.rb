# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Transmissions::ButtonLabelComponent, type: :component do
  let!(:transmission) { create(:transmission, :made_through_web_ui) }
  let!(:report)       { create(:report, :completed, collectivity: transmission.collectivity) }
  let!(:reports)      { create_list(:report, 2, :completed, collectivity: transmission.collectivity) }

  context "without transmission's reports" do
    it "renders blank label" do
      render_inline described_class.new(transmission)

      expect(page).to have_text("Aucun signalement en attente de transmission")
    end
  end

  context "with one transmission's report" do
    before do
      report.update(
        transmission: transmission,
        package: nil,
        reference: nil
      )
    end

    it "renders singular label" do
      render_inline described_class.new(transmission)

      expect(page).to have_text("1 signalement en attente de transmission")
    end
  end

  context "with many transmission's reports" do
    before do
      reports.each do |report|
        report.update(
          transmission: transmission,
          package: nil,
          reference: nil
        )
      end
    end

    it "renders plural label" do
      render_inline described_class.new(transmission)

      expect(page).to have_text("2 signalements en attente de transmission")
    end
  end
end
