# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::Breadcrumbs::Preview do
  it { is_expected.to render_preview_without_exception(:default) }
  it { is_expected.to render_preview_without_exception(:with_actions) }
end
