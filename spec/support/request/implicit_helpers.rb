# frozen_string_literal: true

module RequestTestHelpers
  module ImplicitHelpers
    def response
      subject unless @response
      super
    end

    def flash
      subject unless @response
      super
    end
  end
end
