# frozen_string_literal: true

require "rails_helper"

RSpec.describe Layout::Pagination::Component do
  let(:pagy) { Pagy.new(count: 1025, page: 3, items: 20) }

  context "with only pagy" do
    subject(:component) { described_class.new(pagy) }

    it "renders pages count" do
      render_inline component

      expect(page).to have_text("Page 3 sur 52")
    end

    it "renders buttons" do
      render_inline component

      expect(page).to have_selector(".icon-button", text: "Page précédente")
      expect(page).to have_selector(".icon-button", text: "Page suivante")
    end

    it "renders options" do
      render_inline component

      expect(page).to have_button("Options d'affichage")
      expect(page).to have_selector(".dropdown__menu") do |menu|
        expect(menu).to have_button("Afficher 20 lignes par page")
      end
    end
  end

  context "with model" do
    subject(:component) { described_class.new(pagy, Commune) }

    it "renders resources count" do
      render_inline component

      expect(page).to have_text("1 025 communes | Page 3 sur 52")
    end
  end

  context "with order" do
    subject(:component) { described_class.new(pagy, order: { name: "nom", count: "nombre" }) }

    it "renders order options" do
      render_inline component

      expect(page).to have_button("Options d'affichage")
      expect(page).to have_selector(".dropdown__menu") do |menu|
        expect(menu).to have_link("Trier par nom, par ordre croissant",      href: "/test/components?order=name")
        expect(menu).to have_link("Trier par nom, par ordre décroissant",    href: "/test/components?order=-name")
        expect(menu).to have_link("Trier par nombre, par ordre croissant",   href: "/test/components?order=count")
        expect(menu).to have_link("Trier par nombre, par ordre décroissant", href: "/test/components?order=-count")
      end
    end
  end

  context "with turbo_frame" do
    subject(:component) { described_class.new(pagy, turbo_frame: "content", order: { name: "nom", count: "nombre" }) }

    it "renders buttons" do
      render_inline component

      expect(page).to have_selector(".icon-button[data-turbo-frame='content']", text: "Page précédente")
      expect(page).to have_selector(".icon-button[data-turbo-frame='content']", text: "Page suivante")
    end

    it "renders order options" do
      render_inline component

      expect(page).to have_selector(".icon-button[data-turbo-frame='content']", text: "Trier par nom, par ordre croissant")
      expect(page).to have_selector(".icon-button[data-turbo-frame='content']", text: "Trier par nom, par ordre décroissant")
      expect(page).to have_selector(".icon-button[data-turbo-frame='content']", text: "Trier par nombre, par ordre croissant")
      expect(page).to have_selector(".icon-button[data-turbo-frame='content']", text: "Trier par nombre, par ordre décroissant")
    end
  end
end
