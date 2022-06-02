# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrderColumnComponent, type: :component do
  subject(:component) { described_class.new("commune") }

  let(:current_path) { "/communes" }

  before do
    with_request_url(current_path) do
      render_inline(component)
    end
  end

  it do
    expect(rendered_component).to eq(clean_template(<<~HTML))
      <a aria-label="Trier par ordre croissant"
         class="icon-button datatable__order-button"
         data-turbo-action="advance"
         data-turbo-frame="content"
         href="/communes?order=commune"
      >
        <svg>
          <title>Trier par ordre croissant</title>
          <use href="#arrow-sm-up-icon" />
        </svg>
        <span class="tooltip">Trier par ordre croissant</span>
      </a>
    HTML
  end

  context "when order key exists in parameters" do
    let(:current_path) { "/communes?order=commune" }

    it do
      expect(rendered_component).to eq(clean_template(<<~HTML))
        <a aria-label="Trier par ordre décroissant"
           class="icon-button datatable__order-button datatable__order-button--current"
           data-turbo-action="advance"
           data-turbo-frame="content"
           href="/communes?order=-commune"
        >
          <svg>
            <title>Trier par ordre décroissant</title>
            <use href="#arrow-sm-down-icon" />
          </svg>
          <span class="tooltip">Trier par ordre décroissant</span>
        </a>
      HTML
    end
  end

  context "when reversed key exists in parameters" do
    let(:current_path) { "/communes?order=-commune" }

    it do
      expect(rendered_component).to eq(clean_template(<<~HTML))
        <a aria-label="Trier par ordre croissant"
           class="icon-button datatable__order-button datatable__order-button--current"
           data-turbo-action="advance"
           data-turbo-frame="content"
           href="/communes?order=commune"
        >
          <svg>
            <title>Trier par ordre croissant</title>
            <use href="#arrow-sm-up-icon" />
          </svg>
          <span class="tooltip">Trier par ordre croissant</span>
        </a>
      HTML
    end
  end
end
