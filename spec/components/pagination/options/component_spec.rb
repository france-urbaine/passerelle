# frozen_string_literal: true

require "rails_helper"

RSpec.describe Pagination::Options::Component, type: :component do
  around do |example|
    with_request_url("/territoires/communes") { example.run }
  end

  it "renders a dropdown" do
    render_inline described_class.new(
      Pagy.new(count: 10, page: 1, items: 20)
    )

    expect(page).to have_button("Options d'affichage")
    expect(page).to have_selector(".dropdown__menu") do |menu|
      expect(menu).to have_button(count: 1)
      expect(menu).to have_button("Afficher 20 lignes par page")
      expect(menu).to have_selector(".dropdown__menu") do |sub_menu|
        expect(sub_menu).to have_link(count: 4)
        expect(sub_menu).to have_link("Afficher 10 lignes", href: "/territoires/communes?items=10")
        expect(sub_menu).to have_link("Afficher 20 lignes", href: "/territoires/communes?items=20")
        expect(sub_menu).to have_link("Afficher 50 lignes", href: "/territoires/communes?items=50")
        expect(sub_menu).to have_link("Afficher 100 lignes", href: "/territoires/communes?items=100")
      end
    end
  end

  it "renders order options" do
    render_inline described_class.new(
      Pagy.new(count: 10, page: 1, items: 20),
      order: { name: "nom", count: "nombre" }
    )

    expect(page).to have_button("Options d'affichage")
    expect(page).to have_selector(".dropdown__menu") do |menu|
      expect(menu).to have_button(count: 2)
      expect(menu).to have_button("Trier par défaut")

      expect(menu).to have_selector("div:nth-child(2) > .dropdown__menu") do |sub_menu|
        expect(sub_menu).to have_link(count: 4)
        expect(sub_menu).to have_link("Trier par nom, par ordre croissant",      href: "/territoires/communes?order=name")
        expect(sub_menu).to have_link("Trier par nom, par ordre décroissant",    href: "/territoires/communes?order=-name")
        expect(sub_menu).to have_link("Trier par nombre, par ordre croissant",   href: "/territoires/communes?order=count")
        expect(sub_menu).to have_link("Trier par nombre, par ordre décroissant", href: "/territoires/communes?order=-count")
      end
    end
  end

  it "renders links with actual params" do
    with_request_url("/territoires/communes?search=foo&order=-name&page=3") do
      render_inline described_class.new(
        Pagy.new(count: 125, page: 3, items: 20),
        order: { name: "nom", count: "nombre" }
      )
    end

    aggregate_failures do
      expect(page).to have_link("Afficher 10 lignes", href: "/territoires/communes?items=10&order=-name&search=foo")
      expect(page).to have_link("Afficher 20 lignes", href: "/territoires/communes?items=20&order=-name&search=foo")
      expect(page).to have_link("Afficher 50 lignes", href: "/territoires/communes?items=50&order=-name&search=foo")
      expect(page).to have_link("Afficher 100 lignes", href: "/territoires/communes?items=100&order=-name&search=foo")

      expect(page).to have_button("Trier par nom (desc.)")
      expect(page).to have_link("Trier par nom, par ordre croissant",      href: "/territoires/communes?order=name&search=foo")
      expect(page).to have_link("Trier par nom, par ordre décroissant",    href: "/territoires/communes?order=-name&search=foo")
      expect(page).to have_link("Trier par nombre, par ordre croissant",   href: "/territoires/communes?order=count&search=foo")
      expect(page).to have_link("Trier par nombre, par ordre décroissant", href: "/territoires/communes?order=-count&search=foo")
    end
  end
end
