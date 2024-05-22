# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::Datalist::Component do
  it "renders a datalist" do
    render_inline described_class.new do |datalist|
      datalist.with_option("Chambéry", value: "73065")
      datalist.with_option("Chamonix", value: "74056")
    end

    expect(page).to have_selector(".datalist") do |datalist|
      expect(datalist).to have_selector("li.datalist__option", count: 2)
      expect(datalist).to have_selector("li.datalist__option", text: "Chambéry") do |option|
        expect(option).to have_html_attribute("role").with_value("option")
        expect(option).to have_html_attribute("data-autocomplete-value").with_value("73065")
      end
    end
  end

  it "converts values to JSON when needed" do
    render_inline described_class.new do |datalist|
      datalist.with_option("Chambéry", value: { type: "commune", code: "73065" })
      datalist.with_option("Chamonix", value: { type: "commune", code: "74056" })
    end

    expect(page).to have_selector(".datalist") do |datalist|
      expect(datalist).to have_selector("li.datalist__option", count: 2)
      expect(datalist).to have_selector("li.datalist__option", text: "Chambéry") do |option|
        expect(option).to have_html_attribute("role").with_value("option")
        expect(option).to have_html_attribute("data-autocomplete-value").with_value(
          { type: "commune", code: "73065" }.to_json
        )
      end
    end
  end

  it "highlights query in options" do
    pending "Not implemented"

    render_inline described_class.new(highlight: "Cham") do |datalist|
      datalist.with_option("Chambéry", value: "73065")
      datalist.with_option("Châmonix", value: "74056")
    end

    expect(page).to have_selector(".datalist") do |datalist|
      expect(datalist).to have_selector("li.datalist__option", count: 2)
      expect(datalist).to have_selector("li.datalist__option", text: "Chambéry") do |option|
        expect(option).to have_selector("span.datalist__highlight", text: "Cham", exact_text: true)
      end

      expect(datalist).to have_selector("li.datalist__option", text: "Châmonix") do |option|
        expect(option).to have_selector("span.datalist__highlight", text: "Châm", exact_text: true)
      end
    end
  end
end
