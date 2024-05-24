# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::Form::Autocomplete::Preview do
  it { is_expected.to render_preview_without_exception(:default) }
  it { is_expected.to render_preview_without_exception(:with_options) }
  it { is_expected.to render_preview_without_exception(:with_current_object) }
  it { is_expected.to render_preview_without_exception(:with_custom_fields) }
  it { is_expected.to render_preview_without_exception(:with_formbuilder) }
  it { is_expected.to render_preview_without_exception(:with_noscript) }
end
