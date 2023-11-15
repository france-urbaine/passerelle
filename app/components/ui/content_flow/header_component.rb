# frozen_string_literal: true

module UI
  module ContentFlow
    class HeaderComponent < AbstractBlockComponent
      class CustomPart < ApplicationViewComponent
        attr_reader :options

        def initialize(**options)
          @options = options
          super()
        end

        def call
          content
        end
      end

      renders_one :title, "::UI::ContentFlow::TitleComponent"

      renders_many :parts, types: {
        action: { renders: ::UI::ButtonComponent,                          as: :action },
        status: { renders: ::UI::BadgeComponent,                           as: :status },
        custom: { renders: ::UI::ContentFlow::HeaderComponent::CustomPart, as: :custom }
      }
    end
  end
end
