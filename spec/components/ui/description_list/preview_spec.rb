# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::DescriptionList::Preview do
  it { is_expected.to render_preview_without_exception(:default) }
  it { is_expected.to render_preview_without_exception(:with_record) }
  it { is_expected.to render_preview_without_exception(:with_actions) }
  it { is_expected.to render_preview_without_exception(:with_reference) }
end
