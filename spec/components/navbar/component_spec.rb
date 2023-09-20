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
end
