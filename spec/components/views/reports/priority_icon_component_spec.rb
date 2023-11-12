# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Reports::PriorityIconComponent, type: :component do
  it "renders a low priority icon" do
    report = build_stubbed(:report)
    render_inline described_class.new(report)

    expect(page).to have_selector("svg", count: 1) do |svg|
      expect(svg).to have_html_attribute("data-source").with_value("priority.svg")
      expect(svg).to have_selector("title", text: "Priorité basse")
      expect(svg).to have_selector("path", count: 3)
      expect(svg).to have_html_attribute("class").with_value("low-priority-icon")
    end
  end

  it "renders a medium priority icon" do
    report = build_stubbed(:report, :medium_priority)
    render_inline described_class.new(report)

    expect(page).to have_selector("svg", count: 1) do |svg|
      expect(svg).to have_html_attribute("data-source").with_value("priority.svg")
      expect(svg).to have_selector("title", text: "Priorité moyenne")
      expect(svg).to have_selector("path", count: 3)
      expect(svg).to have_html_attribute("class").with_value("medium-priority-icon")
    end
  end

  it "renders a high priority icon" do
    report = build_stubbed(:report, :high_priority)
    render_inline described_class.new(report)

    expect(page).to have_selector("svg", count: 1) do |svg|
      expect(svg).to have_html_attribute("data-source").with_value("priority.svg")
      expect(svg).to have_selector("title", text: "Priorité haute")
      expect(svg).to have_selector("path", count: 3)
      expect(svg).to have_html_attribute("class").with_value("high-priority-icon")
    end
  end

  it "accepts a priority keyword as input" do
    render_inline described_class.new(:high)

    expect(page).to have_selector("svg", count: 1) do |svg|
      expect(svg).to have_html_attribute("data-source").with_value("priority.svg")
      expect(svg).to have_selector("title", text: "Priorité haute")
      expect(svg).to have_selector("path", count: 3)
      expect(svg).to have_html_attribute("class").with_value("high-priority-icon")
    end
  end
end
