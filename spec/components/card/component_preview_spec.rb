# frozen_string_literal: true

require "rails_helper"

RSpec.describe Card::ComponentPreview, type: :component do
  it { is_expected.to render_preview_without_exception(:default) }
  it { is_expected.to render_preview_without_exception(:with_header) }
  it { is_expected.to render_preview_without_exception(:with_actions) }
end
