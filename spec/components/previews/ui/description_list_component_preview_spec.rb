# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::DescriptionListComponentPreview, type: :component do
  it { is_expected.to render_preview_without_exception(:with_attribute_name) }
  it { is_expected.to render_preview_without_exception(:with_string_label) }
  it { is_expected.to render_preview_without_exception(:with_actions) }
  it { is_expected.to render_preview_without_exception(:with_reference) }
end
