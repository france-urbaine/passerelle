# frozen_string_literal: true

require "rails_helper"

RSpec.describe HiddenField::ComponentPreview, type: :component do
  it { is_expected.to render_preview_without_exception(:default) }
  it { is_expected.to render_preview_without_exception(:with_array_value) }
  it { is_expected.to render_preview_without_exception(:with_hash_value) }
end