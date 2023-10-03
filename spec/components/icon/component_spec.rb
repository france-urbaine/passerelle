# frozen_string_literal: true

require "rails_helper"

RSpec.describe Icon::Component, type: :component do
  it "renders an icon" do
    render_inline described_class.new("x-mark")

    expect(page).to have_selector("svg", count: 1) do |svg|
      aggregate_failures do
        expect(svg).to     have_html_attribute("data-source").with_value("heroicons/optimized/24/outline/x-mark.svg")
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
        expect(svg).not_to have_html_attribute("aria-hidden")
        expect(svg).to have_html_attribute("aria-labelledby")
        expect(svg).to have_selector("title", text: "Supprimer") do |title|
          expect(title).to have_html_attribute("id").with_value(svg["aria-labelledby"])
        end
      end
    end
  end

  it "renders an hidden icon" do
    render_inline described_class.new("x-mark", "Supprimer", hidden: true)

    expect(page).to have_selector("svg", count: 1, visible: :hidden) do |svg|
      expect(svg).to have_html_attribute("hidden").boolean
    end
  end

  it "renders an icon from app/assets folder" do
    render_inline described_class.new("priority")

    expect(page).to have_selector("svg", count: 1) do |svg|
      expect(svg).to have_html_attribute("data-source").with_value("priority.svg")
      expect(svg).to have_selector("path", count: 3)
    end
  end

  it "renders a heroicon with solid variant" do
    render_inline described_class.new("x-mark", variant: :solid)

    expect(page).to have_selector("svg", count: 1) do |svg|
      aggregate_failures do
        expect(svg).to     have_html_attribute("data-source").with_value("heroicons/optimized/24/solid/x-mark.svg")
        expect(svg).to     have_html_attribute("fill").with_value("currentColor")
        expect(svg).not_to have_html_attribute("stroke")

        expect(svg).to have_selector("path[d^='M5.47 5.47a.75.75 0']")
      end
    end
  end
end
