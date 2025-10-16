# frozen_string_literal: true

module Layout
  module StatusPage
    module Forbidden
      class Component < ApplicationViewComponent
        define_component_helper :forbidden_status_page_component

        renders_one  :breadcrumbs, "BreadcrumbsSlot"
        renders_one  :header, "ContentSlot"
        renders_one  :body, "ContentSlot"
        renders_many :actions, "ActionSlot"

        def initialize(reason, **options)
          @reason  = reason
          @options = options
          super()
        end

        def unauthorized_ip?
          @reason.is_a?(ControllerVerifyIp::UnauthorizedIp)
        end
      end
    end
  end
end
