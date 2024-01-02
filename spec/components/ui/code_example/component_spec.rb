# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::CodeExample::Component do
  it "renders a code example" do
    render_inline described_class.new(:shell) do
      "echo 'Hello world'"
    end

    expect(page).to have_selector("pre.code-example") do |pre|
      expect(pre).to have_selector("span.code-example__block > span") do |span|
        expect(span).to have_text("echo 'Hello world'")
        expect(span).to have_html_attribute("data-controller").with_value("highlight")
        expect(span).to have_html_attribute("data-highlight-language-value").with_value("shell")
      end
    end
  end

  it "renders a code example without syntax highlighting" do
    render_inline described_class.new do
      "echo 'Hello world'"
    end

    expect(page).to have_selector("pre.code-example") do |pre|
      expect(pre).to have_selector("span.code-example__block > span") do |span|
        expect(span).to have_text("echo 'Hello world'")
        expect(span).to have_no_html_attribute("data-controller")
        expect(span).to have_no_html_attribute("data-highlight-language-value")
      end
    end
  end

  it "renders a copyable code example" do
    render_inline described_class.new(:shell, copyable: true) do
      "echo 'Hello world'"
    end

    expect(page).to have_selector("pre.code-example") do |pre|
      expect(pre).to have_selector("span.code-example__block > span") do |span|
        expect(span).to have_text("echo 'Hello world'")
        expect(span).to have_html_attribute("data-controller").with_value("highlight")
        expect(span).to have_html_attribute("data-highlight-language-value").with_value("shell")
      end

      expect(pre).to have_selector(".icon-button") do |button|
        expect(button).to have_html_attribute("data-controller").with_value("copy-text toggle")
        expect(button).to have_html_attribute("data-action").with_value("click->copy-text#copy click->toggle#toggle")
        expect(button).to have_html_attribute("data-copy-text-source-value").with_value("echo 'Hello world'")
      end
    end
  end

  it "renders a copyable code example without syntax highlighting" do
    render_inline described_class.new(copyable: true) do
      "echo 'Hello world'"
    end

    expect(page).to have_selector("pre.code-example") do |pre|
      expect(pre).to have_selector(".icon-button") do |button|
        expect(button).to have_html_attribute("data-controller").with_value("copy-text toggle")
        expect(button).to have_html_attribute("data-action").with_value("click->copy-text#copy click->toggle#toggle")
        expect(button).to have_html_attribute("data-copy-text-source-value").with_value("echo 'Hello world'")
      end
    end
  end

  it "renders a command line example" do
    render_inline described_class.new(:command) do
      <<~TEXT
        curl -X GET https://api.passerelle-fiscale.fr/collectivites \\
          -H "Accept: application/json" \\
          -H "Authorization: Bearer $ACCESS_TOKEN"
      TEXT
    end

    expect(page).to have_selector("pre.code-example") do |pre|
      expect(pre).to have_selector("span.code-example__block > span") do |span|
        expect(span).to have_text(<<~TEXT.strip, exact: true)
          $ curl -X GET https://api.passerelle-fiscale.fr/collectivites \\
              -H &quot;Accept: application/json&quot; \\
              -H &quot;Authorization: Bearer $ACCESS_TOKEN&quot;
        TEXT

        expect(span).to have_html_attribute("data-controller").with_value("highlight")
        expect(span).to have_html_attribute("data-highlight-language-value").with_value("shell")
      end
    end
  end

  it "renders a copyable command line example" do
    render_inline described_class.new(:command, copyable: true) do
      <<~TEXT
        curl -X GET https://api.passerelle-fiscale.fr/collectivites \\
          -H "Accept: application/json" \\
          -H "Authorization: Bearer $ACCESS_TOKEN"
      TEXT
    end

    expect(page).to have_selector(".icon-button") do |button|
      expect(button).to have_html_attribute("data-copy-text-source-value").with_value(<<~TEXT)
        curl -X GET https://api.passerelle-fiscale.fr/collectivites \\
          -H "Accept: application/json" \\
          -H "Authorization: Bearer $ACCESS_TOKEN"
      TEXT
    end
  end

  it "renders a code example with a multiple languages" do
    render_inline described_class.new do |code|
      code.with_language(:shell) { "$ http -v GET https://api.example.com/path" }
      code.with_language(:http)  { "HTTP/1.1 200 OK" }
      code.with_language(:json)  { '{ "foo": "bar" }' }
    end

    expect(page).to have_selector("pre.code-example") do |pre|
      expect(pre).to have_text(<<~TEXT.strip, exact: true)
        $ http -v GET https://api.example.com/path

        HTTP/1.1 200 OK

        { "foo": "bar" }
      TEXT

      expect(pre).to have_selector("span.code-example__block", count: 3)
      expect(pre).to have_selector("span.code-example__block > span[data-highlight-language-value=shell]", text: "$ http -v GET https://api.example.com/path")
      expect(pre).to have_selector("span.code-example__block > span[data-highlight-language-value=http]", text: "HTTP/1.1 200 OK")
      expect(pre).to have_selector("span.code-example__block > span[data-highlight-language-value=json]", text: '{ "foo": "bar" }')
    end
  end

  it "renders a code example with a multiple languages, fully copyable" do
    render_inline described_class.new(copyable: true) do |code|
      code.with_language(:shell) { "$ http -v GET https://api.example.com/path" }
      code.with_language(:http)  { "HTTP/1.1 200 OK" }
      code.with_language(:json)  { '{ "foo": "bar" }' }
    end

    expect(page).to have_selector("pre.code-example") do |pre|
      expect(pre).to have_selector(".icon-button", count: 1)
      expect(pre).to have_selector(".icon-button") do |button|
        expect(button).to have_html_attribute("data-copy-text-source-value").with_value(<<~TEXT.strip)
          $ http -v GET https://api.example.com/path

          HTTP/1.1 200 OK

          { "foo": "bar" }
        TEXT
      end
    end
  end

  it "renders a code example with a multiple copyable section" do
    render_inline described_class.new do |code|
      code.with_language(:shell, copyable: true) { "$ http -v GET https://api.example.com/path" }
      code.with_language(:http, copyable: false) { "HTTP/1.1 200 OK" }
      code.with_language(:json, copyable: true)  { '{ "foo": "bar" }' }
    end

    expect(page).to have_selector("pre.code-example") do |pre|
      expect(pre).to have_selector(".icon-button", count: 2)

      expect(pre).to have_selector("span.code-example__block:nth-child(1) > .icon-button") do |button|
        expect(button).to have_html_attribute("data-copy-text-source-value").with_value("$ http -v GET https://api.example.com/path")
      end

      expect(pre).to have_selector("span.code-example__block:nth-child(3) > .icon-button") do |button|
        expect(button).to have_html_attribute("data-copy-text-source-value").with_value('{ "foo": "bar" }')
      end
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
          $ curl -X POST http://api.passerelle-fiscale.localhost:3000/oauth/token
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
        data-copy-text-source-value="$ curl -X POST http://api.passerelle-fiscale.localhost:3000/oauth/token\n  -H &quot;Accept: application/json&quot;\n  -H &quot;Content-Type: application/json&quot;\n  -d '{&quot;a&quot;:&quot;'$A'&quot;, &quot;b&quot;:&quot;'$B'&quot;}'\n"
      HTML
    end
  end
end
