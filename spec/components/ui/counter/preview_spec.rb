# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::Counter::Preview do
  it { is_expected.to render_preview_without_exception(:default) }
  it { is_expected.to render_preview_without_exception(:inside_button) }
end
