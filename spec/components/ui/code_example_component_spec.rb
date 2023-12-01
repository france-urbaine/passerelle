# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::CodeExampleComponent, type: :component do
  it "renders a code example with a given language" do
    render_inline described_class.new(:shell) do
      "$ http -v GET https://api.example.com/path"
    end

    expect(page).to have_selector("pre.code-example") do |pre|
      expect(pre).to have_selector("span.code") do |span|
        expect(span).to have_html_attribute("data-controller").with_value("highlight")
        expect(span).to have_html_attribute("data-highlight-language-value").with_value("shell")
        expect(span).to have_text("$ http -v GET https://api.example.com/path")
      end
      expect(pre).not_to have_button(class: "icon-button")
    end
  end

  it "renders a code example with a given language (copyable)" do
    render_inline described_class.new(:shell, copyable: true) do
      "$ http -v GET https://api.example.com/path"
    end

    expect(page).to have_selector("pre.code-example") do |pre|
      expect(pre).to have_selector("span.code") do |span|
        expect(span).to have_html_attribute("data-controller").with_value("highlight")
        expect(span).to have_html_attribute("data-highlight-language-value").with_value("shell")
        expect(span).to have_text("$ http -v GET https://api.example.com/path")
      end

      expect(pre).to have_selector("div:nth-child(1)") do |div|
        expect(div).to have_button(class: "icon-button") do |copy_button|
          expect(copy_button).to have_html_attribute("data-controller").with_value("copy-text toggle")
          expect(copy_button).to have_html_attribute("data-action").with_value("click->copy-text#copy click->toggle#toggle")
          expect(copy_button).to have_html_attribute("data-copy-text-source-value").with_value("http -v GET https://api.example.com/path")
        end
      end
    end
  end

  it "renders a code example without syntax highlighting" do
    render_inline described_class.new do
      "$ http -v GET https://api.example.com/path"
    end

    expect(page).to have_selector("pre.code-example") do |pre|
      expect(pre).not_to have_html_attribute("data-controller")
      expect(pre).not_to have_html_attribute("data-highlight-language-value")
      expect(pre).to have_text("$ http -v GET https://api.example.com/path")
      expect(pre).not_to have_button(class: "icon-button")
    end
  end

  it "renders a code example without syntax highlighting (copyable)" do
    render_inline described_class.new(copyable: true) do
      "$ http -v GET https://api.example.com/path"
    end

    expect(page).to have_selector("pre.code-example") do |pre|
      expect(pre).to have_selector("span.code") do |span|
        expect(span).not_to have_html_attribute("data-controller")
        expect(span).not_to have_html_attribute("data-highlight-language-value")
        expect(span).to have_text("$ http -v GET https://api.example.com/path")
      end

      expect(pre).to have_selector("div:nth-child(1)") do |div|
        expect(div).to have_button(class: "icon-button") do |copy_button|
          expect(copy_button).to have_html_attribute("data-controller").with_value("copy-text toggle")
          expect(copy_button).to have_html_attribute("data-action").with_value("click->copy-text#copy click->toggle#toggle")
          expect(copy_button).to have_html_attribute("data-copy-text-source-value").with_value("$ http -v GET https://api.example.com/path")
        end
      end
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
      expect(pre).to have_selector("span.code", count: 2)

      expect(pre).to have_selector("span.code:nth-child(1)") do |div|
        expect(div).to have_html_attribute("data-controller").with_value("highlight")
        expect(div).to have_html_attribute("data-highlight-language-value").with_value("shell")
        expect(pre).to have_text("$ http -v GET https://api.example.com/path")
      end

      expect(pre).to have_selector("span.code:nth-child(2)") do |div|
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

  it "renders a code example with a multiple languages (fully copyable)" do
    render_inline described_class.new(copyable: true) do |code|
      code.with_language(:shell) do
        "$ http -v GET https://api.example.com/path"
      end

      code.with_language(:json, copyable: true) do
        '  { "foo": "bar" }'
      end
    end

    expect(page).to have_selector("pre.code-example") do |pre|
      expect(pre).to have_button(class: "icon-button") do |copy_button|
        expect(copy_button).to have_html_attribute("data-controller").with_value("copy-text toggle")
        expect(copy_button).to have_html_attribute("data-action").with_value("click->copy-text#copy click->toggle#toggle")
        expect(copy_button).to have_html_attribute("data-copy-text-source-value").with_value("http -v GET https://api.example.com/path\n\n  { \"foo\": \"bar\" }")
      end

      expect(pre).not_to have_html_attribute("data-controller")
      expect(pre).not_to have_html_attribute("data-highlight-language-value")
      expect(pre).to have_selector("span.code", count: 2)

      expect(pre).to have_selector("span.code:nth-child(2)") do |div|
        expect(div).to have_html_attribute("data-controller").with_value("highlight")
        expect(div).to have_html_attribute("data-highlight-language-value").with_value("shell")

        # copyable flag is already handled over the whole block
        expect(div).not_to have_button(class: "icon-button")

        expect(pre).to have_text("$ http -v GET https://api.example.com/path")
      end

      expect(pre).to have_selector("span.code:nth-child(3)") do |div|
        expect(div).to have_html_attribute("data-controller").with_value("highlight")
        expect(div).to have_html_attribute("data-highlight-language-value").with_value("json")
        expect(pre).to have_text('  { "foo": "bar" }')
      end

      expect(pre).to have_text(<<~TEXT.strip)
        $ http -v GET https://api.example.com/path

          { "foo": "bar" }
      TEXT
    end
  end
end
