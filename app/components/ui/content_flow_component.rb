# frozen_string_literal: true

module UI
  class ContentFlowComponent < ApplicationViewComponent
    renders_many :blocks, types: {

      header: { renders: lambda { |**options|
        (@blocks_list ||= []) << :header
        if options[:separator].nil?
          h_options = options.dup

          # separator before each header, but the first one
          h_options[:separator] = (@blocks_list.size > 1)
        else
          h_options = options
        end
        ::UI::ContentFlow::HeaderComponent.new(**h_options)
      }, as: :header },

      section: { renders: lambda { |**options|
        (@blocks_list ||= []) << :section
        if options[:separator].nil?
          s_options = options.dup

          # separator before each section without header (previous block is also a section), but the first one
          s_options[:separator] = (@blocks_list[-2] == :section)
        else
          s_options = options
        end
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
