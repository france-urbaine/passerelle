# frozen_string_literal: true

require "rails_helper"

RSpec.describe Pagination::Buttons::ComponentPreview, type: :component do
  around do |example|
    # FIXME: url_for helper require a recognized route
    with_request_url("/communes") { example.run }
  end

  it { is_expected.to render_preview_without_exception(:default) }
  it { is_expected.to render_preview_without_exception(:with_turbo_frame) }
end
