# frozen_string_literal: true

module RequestTestHelpers
  module DomHelpers
    def dom_id(...)
      ActionView::RecordIdentifier.dom_id(...)
    end

    def dom_class(...)
      ActionView::RecordIdentifier.dom_class(...)
    end
  end
end
