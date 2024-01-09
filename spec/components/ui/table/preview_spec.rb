# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::Table::Preview, type: :component do
  it { is_expected.to render_preview_without_exception(:default_with_html) }
  it { is_expected.to render_preview_without_exception(:default_with_component) }
  it { is_expected.to render_preview_without_exception(:with_content) }
  it { is_expected.to render_preview_without_exception(:with_formatted_columns) }
  it { is_expected.to render_preview_without_exception(:with_irregular_columns) }
  it { is_expected.to render_preview_without_exception(:with_checkboxes) }
  it { is_expected.to render_preview_without_exception(:with_actions) }
  it { is_expected.to render_preview_without_exception(:with_records) }
end
