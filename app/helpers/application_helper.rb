# frozen_string_literal: true

module ApplicationHelper
  include ComponentHelpers
  include CurrentOrderParams
  include FormHelper
  include FormatHelper
end

ComponentHelpers.eager_load
