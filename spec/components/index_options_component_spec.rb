# frozen_string_literal: true

require "rails_helper"

RSpec.describe IndexOptionsComponent, type: :component do
  subject(:component) { described_class.new(pagy, "commune") }

  def render_component
    with_request_url("/communes") do
      render_inline(component)
    end
  end

  context "with only one resource" do
    let(:pagy) { Pagy.new(count: 1) }

    it "renders page status" do
      render_component
      expect(page).to have_text("1 commune | Page 1 sur 1")
    end

    it "renders a button to show display options" do
      render_component
      expect(page).to have_button("Options d'affichage")
    end
  end

  context "with no resources" do
    let(:pagy) { Pagy.new(count: 0) }

    it "renders page status" do
      render_component
      expect(page).to have_text("0 commune | Page 1 sur 1")
    end

    it "renders a button to show display options" do
      render_component
      expect(page).to have_button("Options d'affichage")
    end
  end

  context "with only one page of multiple resources" do
    let(:pagy) { Pagy.new(count: 10, page: 1) }

    it "renders page status" do
      render_component
      expect(page).to have_text("10 communes | Page 1 sur 1")
    end

    it "renders a button to show display options" do
      render_component
      expect(page).to have_button("Options d'affichage")
    end

    it "renders an inactive icon for previous page", :aggregate_failures do
      render_component
      expect(page).to have_css(".icon-button[aria-hidden][disabled]")
      expect(page).to have_css(".icon-button[aria-hidden][disabled] svg title", text: "Page précédente")
    end

    it "renders an inactive icon for next page", :aggregate_failures do
      render_component
      expect(page).to have_css(".icon-button[aria-hidden][disabled]")
      expect(page).to have_css(".icon-button[aria-hidden][disabled] svg title", text: "Page suivante")
    end
  end

  context "with first page of multiple resources" do
    let(:pagy) { Pagy.new(count: 1200, page: 1) }

    it "renders page status" do
      render_component
      expect(page).to have_text("1 200 communes | Page 1 sur 24")
    end

    it "renders a button to show display options" do
      render_component
      expect(page).to have_button("Options d'affichage")
    end

    it "renders link to next page", :aggregate_failures do
      render_component
      expect(page).to have_css("a.icon-button[href='/communes?page=2'][rel='next']")
      expect(page).to have_css("a.icon-button[href='/communes?page=2'] svg title", text: "Page suivante")
    end

    it "renders an inactive icon for previous page", :aggregate_failures do
      render_component
      expect(page).to have_css(".icon-button[aria-hidden][disabled]")
      expect(page).to have_css(".icon-button[aria-hidden][disabled] svg title", text: "Page précédente")
    end
  end

  context "with last page of multiple resources" do
    let(:pagy) { Pagy.new(count: 1200, page: 24) }

    it "renders page status" do
      render_component
      expect(page).to have_text("1 200 communes | Page 24 sur 24")
    end

    it "renders link to previous page", :aggregate_failures do
      render_component
      expect(page).to have_css("a.icon-button[href='/communes?page=23'][rel='prev']")
      expect(page).to have_css("a.icon-button[href='/communes?page=23'] svg title", text: "Page précédente")
    end

    it "renders an inactive icon for next page", :aggregate_failures do
      render_component
      expect(page).to have_css(".icon-button[aria-hidden][disabled]")
      expect(page).to have_css(".icon-button[aria-hidden][disabled] svg title", text: "Page suivante")
    end
  end

  context "with a middle page of multiple resources" do
    let(:pagy) { Pagy.new(count: 1200, page: 3) }

    it "renders page status" do
      render_component
      expect(page).to have_text("1 200 communes | Page 3 sur 24")
    end

    it "renders link to previous page", :aggregate_failures do
      render_component
      expect(page).to have_css("a.icon-button[href='/communes?page=2'][rel='prev']")
      expect(page).to have_css("a.icon-button[href='/communes?page=2'] svg title", text: "Page précédente")
    end

    it "renders link to next page", :aggregate_failures do
      render_component
      expect(page).to have_css("a.icon-button[href='/communes?page=4'][rel='next']")
      expect(page).to have_css("a.icon-button[href='/communes?page=4'] svg title", text: "Page suivante")
    end
  end

  describe "custom inflections" do
    subject(:component) { described_class.new(pagy, "établissement publique", plural: "établissements publiques") }

    context "with only one resource" do
      let(:pagy) { Pagy.new(page: 1, count: 1) }

      it "renders page status in singular" do
        render_component
        expect(page).to have_text("1 établissement publique")
      end
    end

    context "with no resources" do
      let(:pagy) { Pagy.new(page: 1, count: 0) }

      it "renders page status in singular" do
        render_component
        expect(page).to have_text("0 établissement publique")
      end
    end

    context "with several resources" do
      let(:pagy) { Pagy.new(page: 1, count: 1200) }

      it "renders page status in plural" do
        render_component
        expect(page).to have_text("1 200 établissements publiques")
      end
    end
  end

  describe "order option" do
    subject(:component) { described_class.new(pagy, "commune", order: { name: "nom" }) }

    let(:pagy) { Pagy.new(count: 1200) }

    it "renders links to sort by descending order", :aggregate_failures do
      render_component

      within("div[text='Trier par commune']") do
        expect(page).to have_link("Trier par ordre croissant")
        expect(page).to have_link("Trier par ordre décroissant")
      end
    end
  end
end
