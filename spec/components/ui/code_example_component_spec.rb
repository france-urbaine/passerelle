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

      expect(pre).to have_button(class: "icon-button") do |copy_button|
        expect(copy_button).to have_html_attribute("data-controller").with_value("copy-text toggle")
        expect(copy_button).to have_html_attribute("data-action").with_value("click->copy-text#copy click->toggle#toggle")
        expect(copy_button).to have_html_attribute("data-copy-text-source-value").with_value("http -v GET https://api.example.com/path")
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

      expect(pre).to have_button(class: "icon-button") do |copy_button|
        expect(copy_button).to have_html_attribute("data-controller").with_value("copy-text toggle")
        expect(copy_button).to have_html_attribute("data-action").with_value("click->copy-text#copy click->toggle#toggle")
        expect(copy_button).to have_html_attribute("data-copy-text-source-value").with_value("$ http -v GET https://api.example.com/path")
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

  it "renders a code copying button with proper unescaped content" do
    # FYI: We use `with_content` instead of a block:
    #
    # Text wrapped in a block will be escaped by ActionView rendering
    # If we want to expose HTML escaped characters, they will be over-escaped
    #
    # When passed as an argument to `with_content`, content is not escaped again.
    #
    render_inline described_class.new(:shell, copyable: true).with_content(<<~HTML)
      $ curl -X POST http://api.passerelle-fiscale.localhost:3000/oauth/token
        -H "Accept: application/json"
        -H "Content-Type: application/json"
        -d '{&quot;a&quot;:&quot;'$A'&quot;, &quot;b&quot;:&quot;'$B'&quot;}'
    HTML

    expect(page).to have_button(class: "icon-button") do |copy_button|
      expect(copy_button).to have_html_attribute("data-copy-text-source-value").with_value(
        <<~TEXT
          curl -X POST http://api.passerelle-fiscale.localhost:3000/oauth/token
            -H "Accept: application/json"
            -H "Content-Type: application/json"
            -d '{"a":"'$A'", "b":"'$B'"}'
        TEXT
      )

      # FYI: using `have_html_attribute` can be confusing:
      # the attribute value we are testing is already unsescaped by Nokogiri.
      #
      # If we want to test the raw value of the attribute, we need to
      # perform the following macth:
      #
      expect(copy_button.native.to_html).to include(<<~HTML.strip)
        data-copy-text-source-value="curl -X POST http://api.passerelle-fiscale.localhost:3000/oauth/token\n  -H &quot;Accept: application/json&quot;\n  -H &quot;Content-Type: application/json&quot;\n  -d '{&quot;a&quot;:&quot;'$A'&quot;, &quot;b&quot;:&quot;'$B'&quot;}'\n"
      HTML
    end
  end
end
