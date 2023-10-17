# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Documentation::ExamplesComponent, type: :component do
  let(:resource) do
    { id: "article" }
  end

  let(:method) do
    { name: "index" }
  end

  # rubocop:disable RSpec/AnyInstance
  before do
    allow_any_instance_of(described_class).to receive(:examples).and_return(
      [
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
    )
    Apipie.reload_examples
  end
  # rubocop:enable RSpec/AnyInstance

  it "renders the example" do
    render_inline described_class.new(resource, method)

    expect(page).to have_selector(".http-code.http-code--200", text: "200")

    expect(page).to have_selector(".documentation-examples .tabs__tab", count: 2)
    expect(page).to have_selector(".documentation-examples .tabs") do |tabs|
      aggregate_failures do
        expect(tabs).to have_button("cURL")
        expect(tabs).to have_button("httpie")
      end
    end

    expect(page).to have_selector(".documentation-examples") do |element|
      expect(element).to have_selector("pre", count: 3, visible: :all)
    end
  end
end
