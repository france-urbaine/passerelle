# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::Icon::Preview do
  it { is_expected.to render_preview_without_exception(:default) }
  it { is_expected.to render_preview_without_exception(:with_assets_set) }
  it { is_expected.to render_preview_without_exception(:with_heroicon_outline_set) }
  it { is_expected.to render_preview_without_exception(:with_heroicon_solid_set) }
  it { is_expected.to render_preview_without_exception(:with_title) }
end
