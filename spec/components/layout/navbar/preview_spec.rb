# frozen_string_literal: true

require "rails_helper"

RSpec.describe Layout::Navbar::Preview do
  it { is_expected.to render_preview_without_exception(:default) }
end
