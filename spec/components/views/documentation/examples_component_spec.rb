# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Documentation::ExamplesComponent, type: :component do
  before do
    allow(Apipie.app).to receive(:recorded_examples).and_return(
      {
        "resources#index" => [
          {
            "verb"=>:GET,
            "path"=>"/articles",
            "versions"=>["1.0"],
            "query"=>nil,
            "request_data"=>{ "search"=>{ "title"=>"Titre" } },
            "response_data"=>{ "id"=>"3aad2916-5560-4ce6-9d1e-726fa7b5cfc8" },
            "code"=>200,
            "show_in_doc"=>1,
            "recorded"=>true
          }
        ]
      }
    )
  end

  it "renders the example" do
    render_inline described_class.new("resources", "index")

    expect(page).to have_selector(".http-code.http-code--200", text: "200")

    expect(page).to have_selector(".tabs > .tabs__nav") do |nav|
      expect(nav).to have_button("cURL")
      expect(nav).to have_button("httpie")
    end

    expect(page).to have_selector(".tabs__panel > pre", text: <<~TEXT.strip)
      $ curl -X GET http://api.test.host/articles \\
          -H "Accept: application/json" \\
          -H "Authorization: Bearer $ACCESS_TOKEN" \\
          -H "Content-Type: application/json" \\
          -d '{"search":{"title":"Titre"}}'
    TEXT

    expect(page).to have_selector(".tabs__panel > pre", text: <<~TEXT.strip, visible: :hidden)
      $ http -jv GET http://api.test.host/articles \\
          Accept:"application/json" \\
          Authorization:"Bearer $ACCESS_TOKEN" \\
          --raw='{"search":{"title":"Titre"}}'
    TEXT

    expect(page).to have_selector(".tabs + pre", text: <<~TEXT.strip)
      GET /articles HTTP/1.1
      Accept: application/json
      Authorization: Bearer HgAxkdHZUvlBjuuWweLKwsJ6InRfZoZ-GHyFtbrS03k
      Content-Type: application/json

      {
        "search": {
          "title": "Titre"
        }
      }

      HTTP/1.1 200 OK
      Content-Type: application/json; charset=utf-8

      {
        "id": "3aad2916-5560-4ce6-9d1e-726fa7b5cfc8"
      }
    TEXT
  end
end
