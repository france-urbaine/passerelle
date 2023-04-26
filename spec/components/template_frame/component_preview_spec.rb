# frozen_string_literal: true

require "rails_helper"

RSpec.describe TemplateFrame::ComponentPreview, type: :component do
  it { is_expected.to render_preview_without_exception(:default) }
  it { is_expected.to render_preview_without_exception(:with_async_content) }
  it { is_expected.to render_preview_without_exception(:with_modal) }
  it { is_expected.to render_preview_without_exception(:with_explicit_modal) }
  it { is_expected.to render_preview_without_exception(:with_modal_and_async_background) }
  it { is_expected.to render_preview_without_exception(:with_async_modal) }
end
