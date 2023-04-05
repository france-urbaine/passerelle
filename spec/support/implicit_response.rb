# frozen_string_literal: true

module ImplicitResponse
  def response
    subject unless @response
    super()
  end

  def flash
    subject unless @response
    super()
  end
end
