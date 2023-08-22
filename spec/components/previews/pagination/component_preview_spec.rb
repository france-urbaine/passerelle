# frozen_string_literal: true

require "rails_helper"

RSpec.describe Pagination::ComponentPreview, type: :component do
  it { is_expected.to render_preview_without_exception(:default) }
  it { is_expected.to render_preview_without_exception(:with_countable_model) }
  it { is_expected.to render_preview_without_exception(:with_countable_word) }
  it { is_expected.to render_preview_without_exception(:with_inflections) }
  it { is_expected.to render_preview_without_exception(:with_turbo_frame) }
  it { is_expected.to render_preview_without_exception(:with_orders) }

  it { is_expected.to render_preview_without_exception(:buttons_default) }
  it { is_expected.to render_preview_without_exception(:buttons_with_turbo_frame) }

  it { is_expected.to render_preview_without_exception(:counts_default) }
  it { is_expected.to render_preview_without_exception(:counts_with_countable_model) }
  it { is_expected.to render_preview_without_exception(:counts_with_countable_word) }
  it { is_expected.to render_preview_without_exception(:counts_with_inflections) }

  it { is_expected.to render_preview_without_exception(:options_default) }
  it { is_expected.to render_preview_without_exception(:options_with_turbo_frame) }
  it { is_expected.to render_preview_without_exception(:options_with_direction) }
  it { is_expected.to render_preview_without_exception(:options_with_orders) }
end
