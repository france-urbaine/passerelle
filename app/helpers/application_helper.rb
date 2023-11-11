# frozen_string_literal: true

module ApplicationHelper
  include ApplicationViewComponent::Helpers
  include CurrentOrderParams
  include FormHelper
  include FormatHelper
end

# Eager load components to get all helpers methods available
#
Zeitwerk::Loader.eager_load_namespace(Helpers)
Zeitwerk::Loader.eager_load_namespace(Layout)
Zeitwerk::Loader.eager_load_namespace(UI)
Zeitwerk::Loader.eager_load_namespace(Views)
