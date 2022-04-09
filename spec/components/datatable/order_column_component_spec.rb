# frozen_string_literal: true

require "rails_helper"

RSpec.describe Datatable::OrderColumnComponent, type: :component do
  subject(:component) { described_class.new("commune") }

  let(:current_path) { "/communes" }

  before do
    with_request_url(current_path) { render_inline(component) }
  end

  pending("TODO")
end
