# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::Notification::Preview do
  it { is_expected.to render_preview_without_exception(:default) }
  it { is_expected.to render_preview_without_exception(:with_long_text) }
  it { is_expected.to render_preview_without_exception(:with_custom_icon) }
  it { is_expected.to render_preview_without_exception(:with_actions) }
end
