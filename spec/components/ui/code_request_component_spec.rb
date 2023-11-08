# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::CodeRequestComponent, type: :component do
  let(:verb) { "GET" }
  let(:url) { "https://api.example.com/resource" }
  let(:response) do
    { code: 200, body: { message: "Success" }, headers: { "Content-Length" => "0" } }
  end
  let(:request) do
    { body: { param: "value" }, headers: { "Custom-Header" => "Custom Value" } }
  end

  it "displays the correct cURL command" do
    render_inline described_class.new(verb, url, response: response, request: request, json: true)

    # Test for cURL tab presence
    expect(page).to have_selector("#curl-panel") do |pre|
      aggregate_failures do
        expect(pre).to have_text("$ curl -X #{verb} #{url}")
        expect(pre).to have_text("Custom-Header: Custom Value")
        expect(pre).to have_text("-d '#{request[:body].to_json}'")
      end
    end
  end

  it "displays the correct httpie command" do
    render_inline described_class.new(verb, url, response: response, request: request, json: true)

    # Test for httpie tab presence
    expect(page).to have_selector("#httpie-panel", visible: :all) do |pre|
      aggregate_failures do
        expect(pre).to have_text("$ http -v #{verb} #{url}")
        expect(pre).to have_text("Custom-Header:\"Custom Value\"")
        expect(pre).to have_text("--raw='#{request[:body].to_json}'")
      end
    end
  end

  it "formats the request headers correctly" do
    component = described_class.new(verb, url, response: response, request: request, json: true, authorization: false)
    render_inline component

    expect(component.request_headers_formatted).to eq(request[:headers].map { |key, value|
      [key, value]
    }.sort_by(&:first))
  end

  it "formats the request body correctly" do
    component = described_class.new(verb, url, response: response, request: request, json: true)
    expect(component.request_body_formatted).to eq(request[:body].to_json)
  end

  it "formats the response body correctly" do
    component = described_class.new(verb, url, response: response, request: request, json: true)
    expect(component.response_body_formatted).to eq(response[:body].to_json)
  end
end
