# frozen_string_literal: true

require "rails_helper"

RSpec.describe Button::ComponentPreview, type: :component do
  it { is_expected.to render_preview_without_exception(:default) }
  it { is_expected.to render_preview_without_exception(:default_with_block) }
  it { is_expected.to render_preview_without_exception(:default_with_link) }
  it { is_expected.to render_preview_without_exception(:default_with_link_and_block) }
  it { is_expected.to render_preview_without_exception(:default_with_modal) }
  it { is_expected.to render_preview_without_exception(:default_with_method) }

  it { is_expected.to render_preview_without_exception(:variants_colored) }
  it { is_expected.to render_preview_without_exception(:variants_disabled) }
  it { is_expected.to render_preview_without_exception(:variants_discrete) }
  it { is_expected.to render_preview_without_exception(:variants_discrete_disabled) }
  it { is_expected.to render_preview_without_exception(:variants_with_icon) }
  it { is_expected.to render_preview_without_exception(:variants_with_icon_disabled) }

  it { is_expected.to render_preview_without_exception(:icon_only) }
  it { is_expected.to render_preview_without_exception(:icon_only_with_label) }
  it { is_expected.to render_preview_without_exception(:icon_only_disabled) }
end
