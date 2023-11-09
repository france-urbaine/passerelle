# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::CodeExampleComponent, type: :component do
  it "renders a code example with a given language" do
    render_inline described_class.new(:shell) do
      "$ http -v GET https://api.example.com/path"
    end

    expect(page).to have_selector("pre.code-example") do |pre|
      expect(pre).to have_html_attribute("data-controller").with_value("highlight")
      expect(pre).to have_html_attribute("data-highlight-language-value").with_value("shell")
      expect(pre).to have_text("$ http -v GET https://api.example.com/path")
    end
  end

  it "renders a code example with a multiple languages" do
    render_inline described_class.new do |code|
      code.with_language(:shell) do
        "$ http -v GET https://api.example.com/path"
      end

      code.with_language(:json) do
        '  { "foo": "bar" }'
      end
    end

    expect(page).to have_selector("pre.code-example") do |pre|
      expect(pre).not_to have_html_attribute("data-controller")
      expect(pre).not_to have_html_attribute("data-highlight-language-value")
      expect(pre).to have_selector("span", count: 2)

      expect(pre).to have_selector("span:nth-child(1)") do |div|
        expect(div).to have_html_attribute("data-controller").with_value("highlight")
        expect(div).to have_html_attribute("data-highlight-language-value").with_value("shell")
        expect(pre).to have_text("$ http -v GET https://api.example.com/path")
      end

      expect(pre).to have_selector("span:nth-child(2)") do |div|
        expect(div).to have_html_attribute("data-controller").with_value("highlight")
        expect(div).to have_html_attribute("data-highlight-language-value").with_value("json")
        expect(pre).to have_text('  { "foo": "bar" }')
      end

      expect(pre).to have_text(<<~TEXT.strip, exact: true)
        $ http -v GET https://api.example.com/path

          { "foo": "bar" }
      TEXT
    end
  end
end
