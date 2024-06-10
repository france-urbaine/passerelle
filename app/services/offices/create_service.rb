# frozen_string_literal: true

module Offices
  class CreateService < UpdateService
    # This service class inherits UpdateService setters for territory:
    #   def ddfip_name=

    def initialize(*, ddfip: nil)
      super(*)

      @ddfip = ddfip
    end

    before_save do
      office.ddfip = @ddfip if @ddfip
    end
  end
end
