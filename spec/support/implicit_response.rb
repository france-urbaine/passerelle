# frozen_string_literal: true

module ImplicitResponse
  def response
    subject unless @response
    @response
  end
end
