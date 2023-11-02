# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::DescriptionListComponentPreview, type: :component do
  it { is_expected.to render_preview_without_exception(:with_attribute_name_only) }
  it { is_expected.to render_preview_without_exception(:with_attribute_name_and_content) }
  it { is_expected.to render_preview_without_exception(:with_string_label) }
  it { is_expected.to render_preview_without_exception(:with_actions) }
  it { is_expected.to render_preview_without_exception(:with_reference) }
  it { is_expected.to render_preview_without_exception(:with_blank_value) }
end
