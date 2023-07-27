# frozen_string_literal: true

require "rails_helper"

RSpec.describe Datatable::ComponentPreview, type: :component do
  around do |example|
    with_request_url("/territoires/communes") { example.run }
  end

  it { is_expected.to render_preview_without_exception(:default) }
  it { is_expected.to render_preview_without_exception(:without_records) }
  it { is_expected.to render_preview_without_exception(:with_irregular_columns) }
  it { is_expected.to render_preview_without_exception(:with_checkboxes) }
  it { is_expected.to render_preview_without_exception(:with_actions) }
  it { is_expected.to render_preview_without_exception(:with_sortable_columns) }
  it { is_expected.to render_preview_without_exception(:with_search) }
  it { is_expected.to render_preview_without_exception(:with_pagination) }
  it { is_expected.to render_preview_without_exception(:with_selection_bar) }
end
