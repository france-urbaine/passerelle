# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Reports::PriorityBadge::Component, type: :component do
  it "renders a badge for a report with default prioriy" do
    report = build_stubbed(:report)
    render_inline described_class.new(report)

    expect(page).to have_selector(".badge.badge--lime") do |badge|
      expect(badge).to have_selector("svg") do |svg|
        expect(svg).to have_html_attribute("data-source").with_value("priority.svg")
        expect(svg).to have_selector("title", text: "Priorité basse")
      end
    end
  end

  it "renders a badge for a medium priority" do
    report = build_stubbed(:report, :medium_priority)
    render_inline described_class.new(report)

    expect(page).to have_selector(".badge.badge--yellow") do |badge|
      expect(badge).to have_selector("svg") do |svg|
        expect(svg).to have_html_attribute("data-source").with_value("priority.svg")
        expect(svg).to have_selector("title", text: "Priorité moyenne")
      end
    end
  end

  it "renders a badge for a high priority" do
    report = build_stubbed(:report, :high_priority)
    render_inline described_class.new(report)

    expect(page).to have_selector(".badge.badge--orange") do |badge|
      expect(badge).to have_selector("svg") do |svg|
        expect(svg).to have_html_attribute("data-source").with_value("priority.svg")
        expect(svg).to have_selector("title", text: "Priorité haute")
      end
    end
  end

  it "accepts a priority keyword as input" do
    render_inline described_class.new(:high)

    expect(page).to have_selector(".badge.badge--orange") do |badge|
      expect(badge).to have_selector("svg") do |svg|
        expect(svg).to have_html_attribute("data-source").with_value("priority.svg")
        expect(svg).to have_selector("title", text: "Priorité haute")
      end
    end
  end
end
