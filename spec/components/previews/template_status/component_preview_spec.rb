# frozen_string_literal: true

require "rails_helper"

RSpec.describe TemplateStatus::ComponentPreview, type: :component do
  it { is_expected.to render_preview_without_exception(:default) }
  it { is_expected.to render_preview_without_exception(:not_found) }
  it { is_expected.to render_preview_without_exception(:not_found, params: { model: "user" }) }
  it { is_expected.to render_preview_without_exception(:not_found, params: { model: "other" }) }
  it { is_expected.to render_preview_without_exception(:gone) }
  it { is_expected.to render_preview_without_exception(:gone, params: { model: "ddfip" }) }
  it { is_expected.to render_preview_without_exception(:gone, params: { model: "ddfip_office" }) }
  it { is_expected.to render_preview_without_exception(:gone, params: { model: "other" }) }
end
