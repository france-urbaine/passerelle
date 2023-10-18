# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::IconComponent, type: :component do
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

  it "renders an icon from app/assets folder when available" do
    render_inline described_class.new("priority")

    expect(page).to have_selector("svg", count: 1) do |svg|
      expect(svg).to have_html_attribute("data-source").with_value("priority.svg")
      expect(svg).to have_selector("path", count: 3)
    end
  end

  it "renders an icon from app/assets folder explicitely" do
    render_inline described_class.new("chevron-right-small", set: :assets)

    expect(page).to have_selector("svg", count: 1) do |svg|
      expect(svg).to have_html_attribute("data-source").with_value("chevron-right-small.svg")
    end
  end

  it "renders an heroicon with an explicit set" do
    render_inline described_class.new("chevron-right", set: :heroicon)

    expect(page).to have_selector("svg", count: 1) do |svg|
      expect(svg).to have_html_attribute("data-source").with_value("heroicons/optimized/24/outline/chevron-right.svg")
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

  it "accepts & converts heroicon names in underscore_case" do
    render_inline described_class.new("x_mark", variant: :solid)

    expect(page).to have_selector("svg", count: 1) do |svg|
      expect(svg).to have_html_attribute("data-source").with_value("heroicons/optimized/24/solid/x-mark.svg")
    end
  end

  it "renders an icon with default size" do
    render_inline described_class.new("x-mark")

    expect(page).to have_selector("svg") do |svg|
      aggregate_failures do
        expect(svg).to have_html_attribute("height").with_value("24")
        expect(svg).to have_html_attribute("width").with_value("24")
      end
    end
  end

  it "renders an icon with custom size" do
    render_inline described_class.new("x-mark", height: 12, width: 16)

    expect(page).to have_selector("svg", count: 1) do |svg|
      aggregate_failures do
        expect(svg).to have_html_attribute("height").with_value("12")
        expect(svg).to have_html_attribute("width").with_value("16")
      end
    end
  end

  it "returns a comment when icon is not found" do
    render_inline described_class.new("home-sweet-home")

    expect(page).to have_selector("svg", count: 1) do |svg|
      expect(svg.native.inner_html).to include("<!-- SVG file not found: 'home-sweet-home.svg' -->")
    end
  end

  it "raises an exception when passing an unexpected set" do
    expect {
      render_inline described_class.new("x-mark", set: :material)
    }.to raise_exception(ArgumentError, "unexpected set argument: :material")
  end

  it "raises an exception when passing an unexpected variant" do
    expect {
      render_inline described_class.new("x-mark", variant: :red)
    }.to raise_exception(ArgumentError, "unexpected variant argument: :red")
  end
end
