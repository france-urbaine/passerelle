# frozen_string_literal: true

require "rails_helper"

RSpec.describe Datatable::SearchFormComponent, type: :component do
  subject(:component) { described_class.new("Rechercher des communes") }

  let(:current_path) { "/communes" }

  before do
    with_request_url(current_path) { render_inline(component) }
  end

  pending("TODO")
end
