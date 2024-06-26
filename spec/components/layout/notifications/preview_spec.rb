# frozen_string_literal: true

require "rails_helper"

RSpec.describe Layout::Notifications::Preview do
  it { is_expected.to render_preview_without_exception(:default) }
  it { is_expected.to render_preview_without_exception(:with_actions) }
end
