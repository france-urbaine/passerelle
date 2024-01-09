# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::Copyable::Preview do
  it { is_expected.to render_preview_without_exception(:default) }
  it { is_expected.to render_preview_without_exception(:with_secret) }
  it { is_expected.to render_preview_without_exception(:inside_table) }
  it { is_expected.to render_preview_without_exception(:inside_description_list) }
end
