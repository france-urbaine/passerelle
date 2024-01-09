# frozen_string_literal: true

require "rails_helper"

RSpec.describe UI::Badge::Preview do
  it { is_expected.to render_preview_without_exception(:default) }
  it { is_expected.to render_preview_without_exception(:all_colors) }
  it { is_expected.to render_preview_without_exception(:inside_table) }
  it { is_expected.to render_preview_without_exception(:inside_description_list) }
end
