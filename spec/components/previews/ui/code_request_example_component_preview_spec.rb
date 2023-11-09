# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::CodeRequestExampleComponentPreview, type: :component do
  it { is_expected.to render_preview_without_exception(:default) }
  it { is_expected.to render_preview_without_exception(:with_headers) }
  it { is_expected.to render_preview_without_exception(:with_authorization_header) }
  it { is_expected.to render_preview_without_exception(:with_json_bodies) }
  it { is_expected.to render_preview_without_exception(:with_file_upload) }
  it { is_expected.to render_preview_without_exception(:with_file_download) }
  it { is_expected.to render_preview_without_exception(:inside_card) }
end
