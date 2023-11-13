# frozen_string_literal: true

module UI
  class ContentFlowComponent < ApplicationViewComponent
    define_component_helper :content_flow_component

    renders_many :blocks, types: {

      header: { renders: lambda { |**options|
        h_options = options.dup
        h_options[:block_type] = :header
        ::UI::ContentFlow::HeaderComponent.new(**h_options)
      }, as: :header },

      section: { renders: lambda { |**options|
        s_options = options.dup
        s_options[:block_type] = :section
        ::UI::ContentFlow::SectionComponent.new(**s_options)
      }, as: :section }

    }

    def before_render
      # Eager loading all blocks
      content
      blocks.each(&:to_s)
    end
  end
end
