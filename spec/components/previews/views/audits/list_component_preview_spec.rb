# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Audits::ListComponentPreview, type: :component do
  it { is_expected.to render_preview_without_exception(:default) }
end
