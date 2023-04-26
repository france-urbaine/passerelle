# frozen_string_literal: true

require "rails_helper"

RSpec.describe Modal::ComponentPreview, type: :component do
  it { is_expected.to render_preview_without_exception(:default) }
  it { is_expected.to render_preview_without_exception(:with_header) }
  it { is_expected.to render_preview_without_exception(:with_actions) }
  it { is_expected.to render_preview_without_exception(:with_redirection) }
  it { is_expected.to render_preview_without_exception(:with_form) }
end
