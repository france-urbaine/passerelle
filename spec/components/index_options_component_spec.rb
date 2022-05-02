# frozen_string_literal: true

require "rails_helper"

RSpec.describe IndexOptionsComponent, type: :component do
  subject(:component) { described_class.new(pagy, "commune") }

  let(:pagy)         { Pagy.new(count: 1200, page: 1) }
  let(:current_path) { "/communes" }

  before do
    with_request_url(current_path) do
      render_inline(component)
    end
  end

  it do
    expect(rendered_component).to include(
      %(<b>1 200</b> communes <span class="mx-4">|</span> Page 1 sur 24)
    )
  end

  it do
    expect(rendered_component).to have_selector(
      %(button[aria-label="Options d'affichage du tableau"])
    )
  end

  it do
    expect(rendered_component).to include(clean_template(<<~HTML))
      <span aria-hidden="true" class="icon-button" disabled="true">
        <svg>
          <title>Page précédente</title>
          <use href="#chevron-left-icon">
        </svg>
      </span>
      <a aria-label="Page suivante" class="icon-button" href="/communes?page=2" rel="next">
        <svg>
          <title>Page suivante</title>
          <use href="#chevron-right-icon">
        </svg>
        <span class="tooltip">Page suivante</span>
      </a>
    HTML
  end

  context "when the current page is in the middle" do
    let(:pagy) { Pagy.new(count: 1200, page: 3) }

    it { expect(rendered_component).to include("Page 3 sur 24") }

    it do
      expect(rendered_component).to include(clean_template(<<~HTML))
        <a aria-label="Page précédente" class="icon-button" href="/communes?page=2" rel="prev">
          <svg>
            <title>Page précédente</title>
            <use href="#chevron-left-icon">
          </svg>
          <span class="tooltip">Page précédente</span>
        </a>
        <a aria-label="Page suivante" class="icon-button" href="/communes?page=4" rel="next">
          <svg>
            <title>Page suivante</title>
            <use href="#chevron-right-icon">
          </svg>
          <span class="tooltip">Page suivante</span>
        </a>
      HTML
    end
  end

  context "when the current page is in the last" do
    let(:pagy) { Pagy.new(count: 1200, page: 24) }

    it { expect(rendered_component).to include("Page 24 sur 24") }

    it do
      expect(rendered_component).to include(clean_template(<<~HTML))
        <a aria-label="Page précédente" class="icon-button" href="/communes?page=23" rel="prev">
          <svg>
            <title>Page précédente</title>
            <use href="#chevron-left-icon">
          </svg>
          <span class="tooltip">Page précédente</span>
        </a>
        <span aria-hidden="true" class="icon-button" disabled="true">
          <svg>
            <title>Page suivante</title>
            <use href="#chevron-right-icon">
          </svg>
        </span>
      HTML
    end
  end

  context "with custom words" do
    subject(:component) do
      described_class.new(pagy, "établissement publique", plural: "établissements publiques")
    end

    context "with plural resources" do
      it { expect(rendered_component).to include("<b>1 200</b> établissements publiques") }
    end

    context "with singular resource" do
      let(:pagy) { Pagy.new(count: 1, page: 1) }

      it { expect(rendered_component).to include("<b>1</b> établissement publique") }
    end

    context "without resources" do
      let(:pagy) { Pagy.new(count: 0, page: 1) }

      it { expect(rendered_component).to include("0 établissement publique") }
    end
  end

  context "with order argument" do
    subject(:component) do
      described_class.new(pagy, "commune", order: { commune: "commune" })
    end

    it do
      expect(rendered_component).to include(clean_template(<<~HTML))
        <span class="order-last">Trier par commune</span>
        <a aria-label="Trier par commune, par ordre croissant"
          class="icon-button"
          href="/communes?order=commune"
          role="menuitem"
        >
          <svg>
            <title>Trier par ordre croissant</title>
            <use href="#sort-ascending-icon">
          </svg>
          <span class="tooltip">Trier par ordre croissant</span>
        </a>
        <a aria-label="Trier par commune, par ordre décroissant"
          class="icon-button"
          href="/communes?order=-commune"
          role="menuitem"
        >
          <svg>
            <title>Trier par ordre décroissant</title>
            <use href="#sort-descending-icon">
          </svg>
          <span class="tooltip">Trier par ordre décroissant</span>
        </a>
      HTML
    end
  end
end
