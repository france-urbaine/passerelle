# frozen_string_literal: true

module Views
  module Documentation
    class ExamplesComponent < ApplicationViewComponent
      def initialize(resource_name, method_name, version = nil)
        @resource_name = resource_name
        @method_name   = method_name
        @version       = version

        super()
      end

      def examples
        @examples ||= Apipie.recorded_examples
          .fetch("#{@resource_name}##{@method_name}", [])
          .filter_map do |data|
            Example.new(data) if @version.nil? || (data["versions"].nil? || data["versions"].include?(@version))
          end
      end

      class Example
        def initialize(data)
          @data = data
        end

        def verb
          @data["verb"]
        end

        def path
          @data["path"]
        end

        def code
          @data["code"]
        end

        def http_code_class
          "http-code--#{code.to_i.floor(-2)}"
        end

        def request
          {
            body: @data["request_data"]
          }
        end

        def response
          {
            code: @data["code"],
            body: @data["response_data"]
          }
        end
      end
    end
  end
end
