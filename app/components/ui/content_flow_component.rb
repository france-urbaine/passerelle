# frozen_string_literal: true

module UI
  class ContentFlowComponent < ApplicationViewComponent
    define_component_helper :content_flow_component

    renders_many :blocks, types: {
      header: {
        as: :header,
        renders: lambda { |**options|
          ::UI::ContentFlow::HeaderComponent.new(**options, block_type: :header)
        }
      },
      section: {
        as: :section,
        renders: lambda { |**options|
          ::UI::ContentFlow::SectionComponent.new(**options, block_type: :section)
        }
      }
    }

    def before_render
      # Eager loading all blocks
      content
      blocks.each(&:to_s)
    end
  end
end
