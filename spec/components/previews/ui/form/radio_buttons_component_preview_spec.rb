# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::Form::RadioButtonsComponentPreview do
  it { is_expected.to render_preview_without_exception(:default) }
  it { is_expected.to render_preview_without_exception(:resettable) }
  it { is_expected.to render_preview_without_exception(:with_formbuilder) }
end
