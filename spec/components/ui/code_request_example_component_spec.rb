# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::CodeRequestExampleComponent, type: :component do
  it "renders tabs with multiple commands" do
    render_inline described_class.new("GET", "http://api.test.host/path")

    expect(page).to have_selector(".tabs > .tabs__nav") do |nav|
      expect(nav).to have_button("cURL")
      expect(nav).to have_button("httpie")
    end
  end

  context "without optional arguments" do
    before do
      render_inline described_class.new("GET", "http://api.test.host/path")
    end

    it "renders the correct cURL command" do
      expect(page).to have_selector(".tabs > #curl-panel > pre") do |pre|
        expect(pre).to have_selector("span.code-example__block > span") do |span|
          expect(span).to have_html_attribute("data-highlight-language-value").with_value("shell")
          expect(span).to have_text(<<~TEXT.strip, exact: true)
            $ curl -X GET http://api.test.host/path
          TEXT
        end
      end
    end

    it "renders the correct httpie command" do
      expect(page).to have_selector(".tabs > #httpie-panel > pre", visible: :hidden) do |pre|
        expect(pre).to have_selector("span.code-example__block > span", visible: :hidden) do |span|
          expect(span).to have_html_attribute("data-highlight-language-value").with_value("shell")
          expect(span).to have_text(<<~TEXT.strip, exact: true)
            $ http -v GET http://api.test.host/path
          TEXT
        end
      end
    end

    it "renders http output" do
      expect(page).to have_selector(".tabs + pre", text: <<~TEXT.strip)
        GET /path HTTP/1.1
        Accept: */*

        HTTP/1.1 200 OK
      TEXT
    end
  end

  context "with another host & verb" do
    before do
      render_inline described_class.new("PUT", "https://storage.passerelle-fiscale.fr/some/path")
    end

    it "renders the correct cURL command" do
      expect(page).to have_selector(".tabs > #curl-panel > pre") do |pre|
        expect(pre).to have_selector("span.code-example__block > span") do |span|
          expect(span).to have_html_attribute("data-highlight-language-value").with_value("shell")
          expect(span).to have_text(<<~TEXT.strip, exact: true)
            $ curl -X PUT https://storage.passerelle-fiscale.fr/some/path
          TEXT
        end
      end
    end

    it "renders the correct httpie command" do
      expect(page).to have_selector(".tabs > #httpie-panel > pre", visible: :hidden) do |pre|
        expect(pre).to have_selector("span.code-example__block > span", visible: :hidden) do |span|
          expect(span).to have_html_attribute("data-highlight-language-value").with_value("shell")
          expect(span).to have_text(<<~TEXT.strip, exact: true)
            $ http -v PUT https://storage.passerelle-fiscale.fr/some/path
          TEXT
        end
      end
    end

    it "renders http output" do
      expect(page).to have_selector(".tabs + pre", text: <<~TEXT.strip)
        PUT /some/path HTTP/1.1
        Accept: */*

        HTTP/1.1 200 OK
      TEXT
    end
  end

  context "with custom headers" do
    before do
      render_inline described_class.new(
        "GET", "http://api.test.host/path",
        request: {
          headers: {
            "Accept"        => "application/json",
            "Cache-Control" => "only-if-cached"
          }
        },
        response: {
          headers: {
            "Content-Type" => "application/json; charset=utf-8",
            "ETag"         => 'W/"d457bff2d6ff135822bfd3f86f225060"'
          }
        }
      )
    end

    it "renders the correct cURL command" do
      expect(page).to have_selector(".tabs > #curl-panel > pre", visible: :visible, text: <<~TEXT.strip)
        $ curl -X GET http://api.test.host/path \\
            -H "Accept: application/json" \\
            -H "Cache-Control: only-if-cached"
      TEXT
    end

    it "renders the correct httpie command" do
      expect(page).to have_selector(".tabs > #httpie-panel > pre", visible: :hidden, text: <<~TEXT.strip)
        $ http -v GET http://api.test.host/path \\
            Accept:"application/json" \\
            Cache-Control:"only-if-cached"
      TEXT
    end

    it "renders http output" do
      expect(page).to have_selector(".tabs + pre", text: <<~TEXT.strip)
        GET /path HTTP/1.1
        Accept: application/json
        Cache-Control: only-if-cached

        HTTP/1.1 200 OK
        Content-Type: application/json; charset=utf-8
        ETag: W/"d457bff2d6ff135822bfd3f86f225060"
      TEXT
    end
  end

  context "with authorization header" do
    before do
      render_inline described_class.new("GET", "http://api.test.host/path", authorization: true)
    end

    it "renders the correct cURL command" do
      expect(page).to have_selector(".tabs > #curl-panel > pre", visible: :visible, text: <<~TEXT.strip)
        $ curl -X GET http://api.test.host/path \\
            -H "Authorization: Bearer $ACCESS_TOKEN"
      TEXT
    end

    it "renders the correct httpie command" do
      expect(page).to have_selector(".tabs > #httpie-panel > pre", visible: :hidden, text: <<~TEXT.strip)
        $ http -v GET http://api.test.host/path \\
            Authorization:"Bearer $ACCESS_TOKEN"
      TEXT
    end

    it "renders http output" do
      expect(page).to have_selector(".tabs + pre", text: <<~TEXT.strip)
        GET /path HTTP/1.1
        Accept: */*
        Authorization: Bearer HgAxkdHZUvlBjuuWweLKwsJ6InRfZoZ-GHyFtbrS03k

        HTTP/1.1 200 OK
      TEXT
    end
  end

  context "with JSON headers" do
    before do
      render_inline described_class.new("GET", "http://api.test.host/path", json: true)
    end

    it "renders the correct cURL command" do
      expect(page).to have_selector(".tabs > #curl-panel > pre", visible: :visible, text: <<~TEXT.strip)
        $ curl -X GET http://api.test.host/path \\
            -H "Accept: application/json"
      TEXT
    end

    it "renders the correct httpie command" do
      expect(page).to have_selector(".tabs > #httpie-panel > pre", visible: :hidden, text: <<~TEXT.strip)
        $ http -jv GET http://api.test.host/path
      TEXT
    end

    it "renders http output" do
      expect(page).to have_selector(".tabs + pre", text: <<~TEXT.strip)
        GET /path HTTP/1.1
        Accept: application/json

        HTTP/1.1 200 OK
      TEXT
    end
  end

  context "with JSON bodies" do
    before do
      render_inline described_class.new(
        "GET", "http://api.test.host/path",
        json: true,
        request: {
          body: {
            report: {
              form_type:  "creation_local_habitation",
              code_insee: "64019"
            }
          }
        },
        response: {
          code: 201,
          body: {
            report: {
              id: "255dd254-7713-405a-9097-ca4e0424a536"
            }
          }
        }
      )
    end

    it "renders the correct cURL command" do
      expect(page).to have_selector(".tabs > #curl-panel > pre", visible: :visible, text: <<~TEXT.strip)
        $ curl -X GET http://api.test.host/path \\
            -H "Accept: application/json" \\
            -H "Content-Type: application/json" \\
            -d '{"report":{"form_type":"creation_local_habitation","code_insee":"64019"}}'
      TEXT
    end

    it "renders the correct httpie command" do
      expect(page).to have_selector(".tabs > #httpie-panel > pre", visible: :hidden, text: <<~TEXT.strip)
        $ http -jv GET http://api.test.host/path \\
            Accept:"application/json" \\
            --raw='{"report":{"form_type":"creation_local_habitation","code_insee":"64019"}}'
      TEXT
    end

    it "renders http output" do
      expect(page).to have_selector(".tabs + pre", text: <<~TEXT.strip)
        GET /path HTTP/1.1
        Accept: application/json
        Content-Type: application/json

        {
          "report": {
            "form_type": "creation_local_habitation",
            "code_insee": "64019"
          }
        }

        HTTP/1.1 201 Created
        Content-Type: application/json; charset=utf-8

        {
          "report": {
            "id": "255dd254-7713-405a-9097-ca4e0424a536"
          }
        }
      TEXT
    end
  end

  context "with file upload" do
    before do
      render_inline described_class.new(
        "PUT", "http://api.test.host/path",
        request: {
          file: "relative/path/to/file.pdf"
        },
        response: {
          code: 204
        }
      )
    end

    it "renders the correct cURL command" do
      expect(page).to have_selector(".tabs > #curl-panel > pre", visible: :visible, text: <<~TEXT.strip)
        $ curl -X PUT http://api.test.host/path \\
            -H "Content-Length: 71475" \\
            -H "Content-Type: application/pdf" \\
            --data-binary @relative/path/to/file.pdf
      TEXT
    end

    it "renders the correct httpie command" do
      expect(page).to have_selector(".tabs > #httpie-panel > pre", visible: :hidden, text: <<~TEXT.strip)
        $ http -v PUT http://api.test.host/path \\
            @relative/path/to/file.pdf
      TEXT
    end

    it "renders http output" do
      expect(page).to have_selector(".tabs + pre", text: <<~TEXT.strip)
        PUT /path HTTP/1.1
        Accept: */*
        Content-Length: 71475
        Content-Type: application/pdf

        +-----------------------------------------+
        | NOTE: binary data not shown in terminal |
        +-----------------------------------------+

        HTTP/1.1 204 No Content
      TEXT
    end
  end

  context "with file download" do
    before do
      render_inline described_class.new(
        "GET", "http://api.test.host/path",
        response: {
          file: "relative/path/to/file.pdf"
        }
      )
    end

    it "renders the correct cURL command" do
      expect(page).to have_selector(".tabs > #curl-panel > pre", visible: :visible, text: <<~TEXT.strip)
        $ curl -X GET http://api.test.host/path
      TEXT
    end

    it "renders the correct httpie command" do
      expect(page).to have_selector(".tabs > #httpie-panel > pre", visible: :hidden, text: <<~TEXT.strip)
        $ http -v GET http://api.test.host/path
      TEXT
    end

    it "renders http output" do
      expect(page).to have_selector(".tabs + pre", text: <<~TEXT.strip)
        GET /path HTTP/1.1
        Accept: */*

        HTTP/1.1 200 OK
        Content-Length: 71475
        Content-Type: application/pdf

        +-----------------------------------------+
        | NOTE: binary data not shown in terminal |
        +-----------------------------------------+
      TEXT
    end
  end

  context "with variable interpolations" do
    before do
      render_inline described_class.new(
        "GET", "http://api.test.host/path/$VARIABLE/path",
        authorization: true,
        request: {
          headers: {
            "X-Foo" => "ABC-$FOO"
          }
        },
        interpolations: {
          ACCESS_TOKEN: "88mVFHFMbZL08IFM",
          VARIABLE:     "123456",
          FOO:          "DEF"
        }
      )
    end

    it "renders the correct cURL command" do
      expect(page).to have_selector(".tabs > #curl-panel > pre", visible: :visible, text: <<~TEXT.strip)
        $ curl -X GET http://api.test.host/path/$VARIABLE/path \\
            -H "Authorization: Bearer $ACCESS_TOKEN" \\
            -H "X-Foo: ABC-$FOO"
      TEXT
    end

    it "renders the correct httpie command" do
      expect(page).to have_selector(".tabs > #httpie-panel > pre", visible: :hidden, text: <<~TEXT.strip)
        $ http -v GET http://api.test.host/path/$VARIABLE/path \\
            Authorization:"Bearer $ACCESS_TOKEN" \\
            X-Foo:"ABC-$FOO"
      TEXT
    end

    it "renders http output" do
      expect(page).to have_selector(".tabs + pre", text: <<~TEXT.strip)
        GET /path/123456/path HTTP/1.1
        Accept: */*
        Authorization: Bearer 88mVFHFMbZL08IFM
        X-Foo: ABC-DEF

        HTTP/1.1 200 OK
      TEXT
    end
  end
end
