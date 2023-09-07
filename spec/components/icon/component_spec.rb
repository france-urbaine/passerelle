# frozen_string_literal: true

require "rails_helper"

RSpec.describe Icon::Component, type: :component do
  it "renders an icon" do
    render_inline described_class.new("x-mark")

    expect(page).to have_selector("svg", count: 1) do |svg|
      aggregate_failures do
        expect(svg).to     have_html_attribute("stroke").with_value("currentColor")
        expect(svg).to     have_html_attribute("fill").with_value("none")
        expect(svg).to     have_html_attribute("aria-hidden").boolean
        expect(svg).not_to have_html_attribute("class")

        expect(svg).to have_selector("path[d='M6 18L18 6M6 6l12 12']")
      end
    end
  end

  it "renders an icon with ARIA title" do
    render_inline described_class.new("x-mark", "Supprimer")

    expect(page).to have_selector("svg", count: 1) do |svg|
      aggregate_failures do
        expect(svg).to have_selector("title", text: "Supprimer")
        expect(svg).to have_html_attribute("aria-labelledby")
      end
    end
  end

  it "renders an icon from app/assets folder" do
    render_inline described_class.new("priority")

    expect(page).to have_selector("svg", count: 1) do |svg|
      expect(svg).to have_selector("path", count: 3)
    end
  end

  it "renders a heroicon with solid variant" do
    render_inline described_class.new("x-mark", variant: :solid)

    expect(page).to have_selector("svg", count: 1) do |svg|
      aggregate_failures do
        expect(svg).to     have_html_attribute("fill").with_value("currentColor")
        expect(svg).not_to have_html_attribute("stroke")

        expect(svg).to have_selector("path[d^='M5.47 5.47a.75.75 0']")
      end
    end
  end
end