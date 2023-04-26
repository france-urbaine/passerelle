# frozen_string_literal: true

require "rails_helper"

RSpec.describe Button::ComponentPreview, type: :component do
  it { is_expected.to render_preview_without_exception(:default) }
  it { is_expected.to render_preview_without_exception(:with_block) }
  it { is_expected.to render_preview_without_exception(:with_link) }
  it { is_expected.to render_preview_without_exception(:with_modal) }
  it { is_expected.to render_preview_without_exception(:with_method) }
  it { is_expected.to render_preview_without_exception(:primary) }
  it { is_expected.to render_preview_without_exception(:destructive) }
  it { is_expected.to render_preview_without_exception(:with_icon) }
  it { is_expected.to render_preview_without_exception(:primary_with_icon) }
  it { is_expected.to render_preview_without_exception(:destructive_with_icon) }
  it { is_expected.to render_preview_without_exception(:disabled_with_icon) }
  it { is_expected.to render_preview_without_exception(:primary_disabled_with_icon) }
  it { is_expected.to render_preview_without_exception(:destructive_disabled_with_icon) }
  it { is_expected.to render_preview_without_exception(:with_only_icon) }
  it { is_expected.to render_preview_without_exception(:with_tooltip) }
  it { is_expected.to render_preview_without_exception(:primary_only_icon) }
  it { is_expected.to render_preview_without_exception(:destructive_only_icon) }
  it { is_expected.to render_preview_without_exception(:disabled_with_only_icon) }
  it { is_expected.to render_preview_without_exception(:primary_disabled_only_icon) }
  it { is_expected.to render_preview_without_exception(:destructive_disabled_only_icon) }
end
