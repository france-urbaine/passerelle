# frozen_string_literal: true

require "rails_helper"

RSpec.describe Layout::ContentLayout::Preview do
  it { is_expected.to render_preview_without_exception(:default) }
  it { is_expected.to render_preview_without_exception(:with_actions) }
  it { is_expected.to render_preview_without_exception(:with_components) }
  it { is_expected.to render_preview_without_exception(:with_grid_more_columns) }
  it { is_expected.to render_preview_without_exception(:with_grid) }
  it { is_expected.to render_preview_without_exception(:with_icons) }
  it { is_expected.to render_preview_without_exception(:with_simpler_dsl_grid) }
  it { is_expected.to render_preview_without_exception(:with_simpler_dsl) }
end
