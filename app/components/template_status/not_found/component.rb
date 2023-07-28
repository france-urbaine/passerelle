# frozen_string_literal: true

module TemplateStatus
  module NotFound
    class Component < TemplateStatus::Component
      def initialize(model, **options)
        @model = model
        @options = options
        super()
      end
    end
  end
end
