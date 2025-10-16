# frozen_string_literal: true

require "rails_helper"

RSpec.describe Layout::StatusPage::Preview do
  it { is_expected.to render_preview_without_exception(:default) }
  it { is_expected.to render_preview_without_exception(:forbidden) }
  it { is_expected.to render_preview_without_exception(:forbidden, params: { exception: "unauthorized_ip" }) }
  it { is_expected.to render_preview_without_exception(:forbidden, params: { exception: "action_policy" }) }
  it { is_expected.to render_preview_without_exception(:forbidden, params: { exception: "other" }) }
  it { is_expected.to render_preview_without_exception(:not_found) }
  it { is_expected.to render_preview_without_exception(:not_found, params: { model: "user" }) }
  it { is_expected.to render_preview_without_exception(:not_found, params: { model: "other" }) }
  it { is_expected.to render_preview_without_exception(:gone) }
  it { is_expected.to render_preview_without_exception(:gone, params: { model: "ddfip" }) }
  it { is_expected.to render_preview_without_exception(:gone, params: { model: "ddfip_office" }) }
  it { is_expected.to render_preview_without_exception(:gone, params: { model: "other" }) }
end
