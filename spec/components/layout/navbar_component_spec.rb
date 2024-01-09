# frozen_string_literal: true

require "rails_helper"

RSpec.describe Layout::NavbarComponent, type: :component do
  subject(:render_default_navbar) do
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
    render_default_navbar

    expect(page).to have_selector(".navbar") do |navbar|
      expect(navbar).to have_selector("span.brand__left", text: "Passe")
      expect(navbar).to have_selector("span.brand__right", text: "relle")
      expect(navbar).to have_link("Tableau de bord")
      expect(navbar).to have_link("Signalements")
      expect(navbar).to have_link("Paquets")
    end
  end

  it "renders a tablet navbar" do
    sign_in
    render_default_navbar

    expect(page).to have_selector(".navbar.navbar--tablet") do |navbar|
      expect(navbar).to have_link("Tableau de bord")
      expect(navbar).to have_link("Signalements")
      expect(navbar).to have_link("Paquets")
    end
  end

  it "renders a mobile navbar" do
    sign_in
    render_default_navbar

    expect(page).to have_selector(".navbar.navbar--mobile") do |navbar|
      expect(navbar).to have_link("Tableau de bord")
      expect(navbar).to have_link("Signalements")
      expect(navbar).to have_link("Paquets")
    end
  end

  it "marks current link" do
    sign_in
    with_request_url "/signalements" do
      render_default_navbar
    end

    expect(page).to have_selector(".navbar") do |navbar|
      expect(navbar).to have_selector(".navbar__link--current", count: 1)
      expect(navbar).to have_selector("a.navbar__link--current", text: "Signalements")
    end
  end

  it "marks current link even when current URL has some params" do
    sign_in
    with_request_url "/signalements?search=whatever" do
      render_default_navbar
    end

    expect(page).to have_selector(".navbar") do |navbar|
      expect(navbar).to have_selector(".navbar__link--current", count: 1)
      expect(navbar).to have_selector("a.navbar__link--current", text: "Signalements")
    end
  end

  it "marks homepage link as current" do
    sign_in
    with_request_url "/" do
      render_default_navbar
    end

    expect(page).to have_selector(".navbar") do |navbar|
      expect(navbar).to have_selector(".navbar__link--current", count: 1)
      expect(navbar).to have_selector("a.navbar__link--current", text: "Tableau de bord")
    end
  end

  it "marks homepage link as current even when current URL has some params" do
    sign_in
    with_request_url "/?search=whatever" do
      render_default_navbar
    end

    expect(page).to have_selector(".navbar") do |navbar|
      expect(navbar).to have_selector(".navbar__link--current", count: 1)
      expect(navbar).to have_selector("a.navbar__link--current", text: "Tableau de bord")
    end
  end

  it "renders disabled links" do
    sign_in
    render_inline described_class.new do |navbar|
      navbar.with_section("Echanges") do |section|
        section.with_link("Tableau de bord", "/", disabled: true)
        section.with_link("Signalements",    "/signalements")
      end
    end

    expect(page).to have_selector(".navbar") do |navbar|
      expect(navbar).to have_selector("a[disabled]", text: "Tableau de bord")
    end
  end

  it "renders a navbar with header" do
    render_inline described_class.new do |navbar|
      navbar.with_header do
        "<span class='brand__right'>API</span>".html_safe
      end
    end

    expect(page).to have_selector(".navbar") do |navbar|
      expect(navbar).to have_selector("span.brand__right", text: "API")
      expect(navbar).to have_no_selector("span.brand__left")
    end
  end

  it "renders a navbar with a custom CSS class" do
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

  it "raises en exception with missing link arguments" do
    sign_in

    expect {
      render_inline described_class.new do |navbar|
        navbar.with_section("References") do |section|
          section.with_link do
            "Collectivities"
          end
        end
      end
    }.to raise_exception(ArgumentError, "wrong number of arguments (given 0, expected 1..2)")
  end

  it "doesn't render a section without links" do
    sign_in
    render_inline described_class.new do |navbar|
      navbar.with_section("Part 1") do |section|
        section.with_link("Link 1.1")
      end

      navbar.with_section("Part 2") do |_section|
        # No links
      end
    end

    expect(page).to have_selector(".navbar") do |navbar|
      expect(navbar).to have_text("Part 1")
      expect(navbar).to have_no_text("Part 2")
    end
  end

  it "doesn't render a section when subsections have no links" do
    sign_in
    render_inline described_class.new do |navbar|
      navbar.with_section("Part 1") do |section|
        section.with_subsection("Part 1.1") do |subsection|
          subsection.with_link("Link 1.1.1")
        end

        section.with_subsection("Part 1.2") do |_subsection|
          # No links
        end
      end

      navbar.with_section("Part 2") do |section|
        section.with_subsection("Part 2.1") do |_subsection|
          # No links
        end
      end
    end

    expect(page).to have_selector(".navbar") do |navbar|
      expect(navbar).to have_text("Part 1")
      expect(navbar).to have_text("Part 1.1")
      expect(navbar).to have_no_text("Part 1.2")
      expect(navbar).to have_no_text("Part 2")
    end
  end
end
