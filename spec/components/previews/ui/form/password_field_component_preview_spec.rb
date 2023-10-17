# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::Form::PasswordFieldComponentPreview, type: :component do
  it { is_expected.to render_preview_without_exception(:default) }
  it { is_expected.to render_preview_without_exception(:with_strength_test) }
  it { is_expected.to render_preview_without_exception(:with_formbuilder) }
end
