# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::ContentFlowComponentPreview, type: :component do
  it { is_expected.to render_preview_without_exception(:section_with_header_and_actions) }
  it { is_expected.to render_preview_without_exception(:section_with_datatable) }
  it { is_expected.to render_preview_without_exception(:section_with_separator) }
  it { is_expected.to render_preview_without_exception(:section_without_header) }
end
