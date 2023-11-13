# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::CounterComponentPreview, type: :component do
  it { is_expected.to render_preview_without_exception(:default) }
  it { is_expected.to render_preview_without_exception(:inside_button) }
end