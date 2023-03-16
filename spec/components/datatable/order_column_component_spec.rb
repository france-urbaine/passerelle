# frozen_string_literal: true

require "rails_helper"

RSpec.describe Datatable::OrderColumnComponent, type: :component do
  subject(:component) { described_class.new("name") }

  context "without params" do
    before do
      with_request_url("/communes") do
        render_inline(component)
      end
    end

    it "renders a link to sort by ascending order" do
      expect(page).to have_link("Trier par ordre croissant", href: "/communes?order=name")
    end

    it "renders a tooltip" do
      expect(page).to have_css(".tooltip", text: "Trier par ordre croissant")
    end

    it "renders an icon to sort by ascending order" do
      within("svg") do
        expect(page).to have_css("title", tex: "Trier par ordre croissant")
      end
    end
  end

  context "when already sort by ascending order" do
    before do
      with_request_url("/communes?order=name") do
        render_inline(component)
      end
    end

    it "renders a link to sort by descending order" do
      expect(page).to have_link("Trier par ordre décroissant", href: "/communes?order=-name")
    end

    it "renders a tooltip" do
      expect(page).to have_css(".tooltip", text: "Trier par ordre décroissant")
    end

    it "renders an icon to sort by descending order" do
      within("svg") do
        expect(page).to have_css("title", tex: "Trier par ordre décroissant")
      end
    end
  end

  context "when already sort by descending order" do
    before do
      with_request_url("/communes?order=-name") do
        render_inline(component)
      end
    end

    it "renders a link to sort by ascending order" do
      expect(page).to have_link("Trier par ordre croissant", href: "/communes?order=name")
    end

    it "renders a tooltip" do
      expect(page).to have_css(".tooltip", text: "Trier par ordre croissant")
    end

    it "renders an icon to sort by ascending order" do
      within("svg") do
        expect(page).to have_css("title", tex: "Trier par ordre acroissant")
      end
    end
  end

  context "when already sort by another key" do
    before do
      with_request_url("/communes?order=code_insee") do
        render_inline(component)
      end
    end

    it "renders a link to sort by ascending order" do
      expect(page).to have_link("Trier par ordre croissant", href: "/communes?order=name")
    end

    it "renders an icon to sort by ascending order" do
      within("svg") do
        expect(page).to have_css("title", tex: "Trier par ordre acroissant")
      end
    end
  end
end
