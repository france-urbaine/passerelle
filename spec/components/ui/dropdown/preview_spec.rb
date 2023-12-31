# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::Dropdown::Preview do
  it { is_expected.to render_preview_without_exception(:default) }
  it { is_expected.to render_preview_without_exception(:with_icon_button) }
  it { is_expected.to render_preview_without_exception(:with_position_below_right) }
  it { is_expected.to render_preview_without_exception(:with_position_aside_right) }
  it { is_expected.to render_preview_without_exception(:with_position_below_left) }
  it { is_expected.to render_preview_without_exception(:with_position_aside_left) }
  it { is_expected.to render_preview_without_exception(:with_nested_menus_right) }
  it { is_expected.to render_preview_without_exception(:with_nested_menus_left) }
  it { is_expected.to render_preview_without_exception(:with_custom_items) }
end
