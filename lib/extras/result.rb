# frozen_string_literal: true

# A simple Result monad to return success and failure.
# Compatible with responders, it could passed to `respond_with`:
#
#   result = service.do_something
#   respond_with result, location: some_path
#
class Result
  class Success < self
    attr_reader :record

    def initialize(record)
      @record = record
      super()
    end
  end

  class Failure < self
    attr_reader :errors

    def initialize(errors)
      @errors = errors
      super()
    end
  end

  def success?
    is_a?(Success)
  end

  def failure?
    is_a?(Failure)
  end

  alias successful? success?
  alias failed? failure?
end
