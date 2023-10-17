# frozen_string_literal: true

require "rails_helper"

RSpec.describe Layout::ModalFrameComponentPreview, type: :component do
  it { is_expected.to render_preview_without_exception(:default) }
  it { is_expected.to render_preview_without_exception(:with_async_background) }
  it { is_expected.to render_preview_without_exception(:with_explicit_modal) }
end
