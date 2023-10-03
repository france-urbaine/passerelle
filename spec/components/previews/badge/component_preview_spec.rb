# frozen_string_literal: true

require "rails_helper"

RSpec.describe Badge::ComponentPreview, type: :component do
  it { is_expected.to render_preview_without_exception(:default) }
  it { is_expected.to render_preview_without_exception(:all_colors) }
  it { is_expected.to render_preview_without_exception(:report_badges) }
  it { is_expected.to render_preview_without_exception(:package_badges) }
  it { is_expected.to render_preview_without_exception(:priority_badges) }
end
