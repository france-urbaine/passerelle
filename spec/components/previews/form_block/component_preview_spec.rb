# frozen_string_literal: true

require "rails_helper"

RSpec.describe FormBlock::ComponentPreview, type: :component do
  it { is_expected.to render_preview_without_exception(:text_fields) }
  it { is_expected.to render_preview_without_exception(:select) }
  it { is_expected.to render_preview_without_exception(:check_box) }
  it { is_expected.to render_preview_without_exception(:radio_button) }
  it { is_expected.to render_preview_without_exception(:text_field_with_hint) }
  it { is_expected.to render_preview_without_exception(:text_field_with_errors) }
  it { is_expected.to render_preview_without_exception(:text_field_with_validation_errors) }
  it { is_expected.to render_preview_without_exception(:text_field_with_messages) }
  it { is_expected.to render_preview_without_exception(:check_box_with_hint) }
  it { is_expected.to render_preview_without_exception(:autocompletion) }
end
