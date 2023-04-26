# frozen_string_literal: true

require "rails_helper"

RSpec.describe Notification::ComponentPreview, type: :component do
  it { is_expected.to render_preview_without_exception(:default) }
  it { is_expected.to render_preview_without_exception(:with_type_information) }
  it { is_expected.to render_preview_without_exception(:with_type_success) }
  it { is_expected.to render_preview_without_exception(:with_type_error) }
  it { is_expected.to render_preview_without_exception(:with_type_cancel) }
  it { is_expected.to render_preview_without_exception(:with_description) }
  it { is_expected.to render_preview_without_exception(:with_actions) }
end
