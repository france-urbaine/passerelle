# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::CodeExample::Preview do
  it { is_expected.to render_preview_without_exception(:default) }
  it { is_expected.to render_preview_without_exception(:with_command_lines) }
  it { is_expected.to render_preview_without_exception(:with_multiple_languages) }
  it { is_expected.to render_preview_without_exception(:inside_card) }
end
