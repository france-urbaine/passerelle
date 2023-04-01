# frozen_string_literal: true

require "rails_helper"

RSpec.describe SearchComponent, type: :component do
  subject(:component) { described_class.new }

  it "renders a form" do
    render_inline(component)

    expect(page).to have_css("form.search")
  end

  it "renders default label and placeholder" do
    render_inline(component)

    expect(page).to have_field("Rechercher", type: "search", name: "search", placeholder: "Rechercher")
  end

  it "renders an alternative label and placeholder" do
    component = described_class.new(label: "Rechercher des communes")
    render_inline(component)

    expect(page).to have_field("Rechercher des communes", type: "search", name: "search", placeholder: "Rechercher des communes")
  end

  it "hides the SVG icon from ARIA" do
    render_inline(component)

    expect(page).to have_css("svg[aria-hidden]")
  end

  it "renders URL params into inputs" do
    with_request_url("/communes?search=Pyrenees&order=-departement&page=2") do
      render_inline(component)
    end

    aggregate_failures do
      expect(page).to have_css("input[type='search'][name='search'][value='Pyrenees']")
      expect(page).to have_css("input[type='hidden'][name='order'][value='-departement']", visible: :all)
    end
  end
end
