# frozen_string_literal: true

require "rails_helper"

RSpec.describe Javascript::SwitchPreview, type: :preview do
  it { is_expected.to render_preview_without_exception(:default) }
  it { is_expected.to render_preview_without_exception(:on_fieldsets) }
  it { is_expected.to render_preview_without_exception(:other_visibility) }
  it { is_expected.to render_preview_without_exception(:with_a_separator) }
  it { is_expected.to render_preview_without_exception(:with_an_array) }
  it { is_expected.to render_preview_without_exception(:with_checkboxes) }
  it { is_expected.to render_preview_without_exception(:with_multiple_inputs) }
end
