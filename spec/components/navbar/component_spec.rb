# frozen_string_literal: true

require "rails_helper"

RSpec.describe Navbar::Component, type: :component do
  subject(:render_component) do
    render_inline described_class.new do |navbar|
      navbar.with_section("Echanges") do |section|
        section.with_link("Tableau de bord", "/",             icon: "home")
        section.with_link("Signalements",    "/signalements", icon: "document-duplicate")
        section.with_link("Paquets",         "/paquets",      icon: "archive-box")
      end
    end
  end

  it "renders the desktop navbar" do
    sign_in
    render_component

    expect(page).to have_selector(".navbar") do |navbar|
      aggregate_failures do
        expect(navbar).to have_selector("span.brand__left", text: "Fisca")
        expect(navbar).to have_selector("span.brand__right", text: "Hub")
        expect(navbar).to have_link("Tableau de bord")
        expect(navbar).to have_link("Signalements")
        expect(navbar).to have_link("Paquets")
      end
    end
  end

  it "renders a tablet navbar" do
    sign_in
    render_component

    expect(page).to have_selector(".navbar.navbar--tablet") do |navbar|
      aggregate_failures do
        expect(navbar).to have_link("Tableau de bord")
        expect(navbar).to have_link("Signalements")
        expect(navbar).to have_link("Paquets")
      end
    end
  end

  it "renders a mobile navbar" do
    sign_in
    render_component

    expect(page).to have_selector(".navbar.navbar--mobile") do |navbar|
      aggregate_failures do
        expect(navbar).to have_link("Tableau de bord")
        expect(navbar).to have_link("Signalements")
        expect(navbar).to have_link("Paquets")
      end
    end
  end

  it "renders a navbar with header" do
    render_inline described_class.new do |navbar|
      navbar.with_header do
        "<span class='brand__right'>API</span>".html_safe
      end
    end

    expect(page).to have_selector(".navbar") do |navbar|
      aggregate_failures do
        expect(navbar).to     have_selector("span.brand__right", text: "API")
        expect(navbar).not_to have_selector("span.brand__left")
      end
    end
  end

  it "renders a mobile options" do
    sign_in
    render_inline described_class.new(class: "navbar--api")

    expect(page).to have_selector(".navbar.navbar--api")
  end

  it "renders links with custom html content" do
    sign_in

    render_inline described_class.new do |navbar|
      navbar.with_section("References") do |section|
        section.with_link("/some_references") do
          # rubocop:disable Style/StringConcatenation
          # String concatenation escape html tags
          tag.div("GET", class: "method") + " /collectivities"
          # rubocop:enable Style/StringConcatenation
        end
      end
    end

    expect(page).to have_selector(".navbar") do |navbar|
      expect(navbar).to have_link("GET /collectivities") do |link|
        expect(link).to have_selector(".method", text: "GET")
      end
    end
  end
end
