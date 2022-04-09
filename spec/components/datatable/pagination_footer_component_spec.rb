# frozen_string_literal: true

require "rails_helper"

RSpec.describe Datatable::PaginationFooterComponent, type: :component do
  subject(:component) { described_class.new(pagy) }

  let(:pagy)         { Pagy.new(count: 103, page: 1) }
  let(:current_path) { "/communes" }

  before do
    with_request_url(current_path) { render_inline(component) }
  end

  def no_space(template)
    template.gsub(/\s*\n\s*/, "")
  end

  it { expect(rendered_component).to include(no_space(<<~HTML)) }
    <select id="footer-page-items" name="items">
    <option value="10">
  HTML

  it { expect(rendered_component).to include(no_space(<<~HTML)) }
    <input type="number" name="page" id="footer-page-input" placeholder="Page 1 / 3" />
  HTML
end
