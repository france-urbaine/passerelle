# frozen_string_literal: true

module UI
  module Timeline
    class Component < ApplicationViewComponent
      define_component_helper :timeline_component
      renders_many :steps, ->(*args, **kwargs) { Step.new(self, *args, **kwargs) }

      attr_reader :date_format

      def initialize(date_format: nil, **)
        @date_format     = date_format || I18n.t("date.formats.default")
        @html_attributes = parse_html_attributes(**)
        super()
      end
    end
  end
end
