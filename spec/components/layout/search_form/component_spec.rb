# frozen_string_literal: true

require "rails_helper"

RSpec.describe Layout::SearchForm::Component do
  it "renders a form with an search input" do
    render_inline described_class.new

    expect(page).to have_selector("form.search") do |form|
      expect(form).to have_field("Rechercher", type: "search", name: "search", placeholder: "Rechercher")
    end
  end

  it "renders an alternative label and placeholder" do
    render_inline described_class.new(label: "Rechercher des communes")

    expect(page).to have_selector("form.search") do |form|
      expect(form).to have_field("Rechercher des communes", type: "search", name: "search", placeholder: "Rechercher des communes")
    end
  end

  it "hides the SVG icon from ARIA" do
    render_inline described_class.new

    expect(page).to have_selector("form.search") do |form|
      expect(form).to have_selector("svg[aria-hidden]")
    end
  end

  it "sends form to top frame by default" do
    render_inline described_class.new

    expect(page).to have_selector("form.search") do |form|
      expect(form["data-turbo-frame"]).to eq("_top")
    end
  end

  it "targets a custom frame" do
    render_inline described_class.new(turbo_frame: "datatable")

    expect(page).to have_selector("form.search") do |form|
      expect(form["data-turbo-frame"]).to eq("datatable")
    end
  end

  it "renders URL params into inputs" do
    with_request_url "/test/components?search=Pyrenees&order=-departement&page=2" do
      render_inline described_class.new
    end

    expect(page).to have_selector("form.search") do |form|
      expect(form).to have_selector("input[type='search'][name='search'][value='Pyrenees']")
      expect(form).to have_selector("input[type='hidden'][name='order'][value='-departement']", visible: :all)
    end
  end
end
