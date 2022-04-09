# frozen_string_literal: true

require "rails_helper"

RSpec.describe Datatable::PaginationHeaderComponent, type: :component do
  subject(:component) { described_class.new(pagy, "commune") }

  let(:pagy)         { Pagy.new(count: 103, page: 1) }
  let(:current_path) { "/communes" }

  before do
    with_request_url(current_path) { render_inline(component) }
  end

  def no_space(template)
    template.gsub(/\s*\n\s*/, "")
  end

  context "when the current page is the first" do
    it { expect(rendered_component).to have_text("103 communes | Page 1 sur 3") }

    it { expect(rendered_component).to include(no_space(<<~HTML)) }
      <span aria-hidden="true" class="icon-button" disabled="true">
        <svg height="20" width="20" aria-hidden="true">
          <use href="#chevron-left-icon">
        </svg>
      </span>
    HTML

    it { expect(rendered_component).to include(no_space(<<~HTML)) }
      <a aria-label="Page suivante" class="icon-button" href="/communes?page=2" rel="next">
        <svg height="20" width="20">
          <title>Page suivante</title>
          <use href="#chevron-right-icon">
        </svg>
      </a>
    HTML
  end

  context "when the current page is in the middle" do
    let(:pagy) { Pagy.new(count: 103, page: 2) }

    it { expect(rendered_component).to have_text("103 communes | Page 2 sur 3") }

    it { expect(rendered_component).to include(no_space(<<~HTML)) }
      <a aria-label="Page précédente" class="icon-button" href="/communes?page=1" rel="prev">
        <svg height="20" width="20">
          <title>Page précédente</title>
          <use href="#chevron-left-icon">
        </svg>
      </a>
    HTML

    it { expect(rendered_component).to include(no_space(<<~HTML)) }
      <a aria-label="Page suivante" class="icon-button" href="/communes?page=3" rel="next">
        <svg height="20" width="20">
          <title>Page suivante</title>
          <use href="#chevron-right-icon">
        </svg>
      </a>
    HTML
  end

  context "when the current page is in the last" do
    let(:pagy) { Pagy.new(count: 103, page: 3) }

    it { expect(rendered_component).to have_text("103 communes | Page 3 sur 3") }

    it { expect(rendered_component).to include(no_space(<<~HTML)) }
      <a aria-label="Page précédente" class="icon-button" href="/communes?page=2" rel="prev">
        <svg height="20" width="20">
          <title>Page précédente</title>
          <use href="#chevron-left-icon">
        </svg>
      </a>
    HTML

    it { expect(rendered_component).to include(no_space(<<~HTML)) }
      <span aria-hidden="true" class="icon-button" disabled="true">
        <svg height="20" width="20" aria-hidden="true">
          <use href="#chevron-right-icon">
        </svg>
      </span>
    HTML
  end

  context "when their is only one page" do
    let(:pagy) { Pagy.new(count: 1, page: 1) }

    it { expect(rendered_component).to have_text("1 commune | Page 1 sur 1") }

    it { expect(rendered_component).to include(no_space(<<~HTML)) }
      <span aria-hidden="true" class="icon-button" disabled="true">
        <svg height="20" width="20" aria-hidden="true">
          <use href="#chevron-left-icon">
        </svg>
      </span>
    HTML

    it { expect(rendered_component).to include(no_space(<<~HTML)) }
      <span aria-hidden="true" class="icon-button" disabled="true">
        <svg height="20" width="20" aria-hidden="true">
          <use href="#chevron-right-icon">
        </svg>
      </span>
    HTML
  end
end
