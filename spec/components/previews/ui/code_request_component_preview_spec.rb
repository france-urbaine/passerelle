# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::CodeRequestComponentPreview, type: :component do
  it { is_expected.to render_preview_without_exception(:default) }
  it { is_expected.to render_preview_without_exception(:with_header) }
  it { is_expected.to render_preview_without_exception(:with_body) }
  it { is_expected.to render_preview_without_exception(:with_file) }
end
