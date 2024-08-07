# frozen_string_literal: true

module Collectivities
  class CreateService < UpdateService
    # This service class inherits UpdateService setters for territory:
    #   def territory_data=
    #   def territory_code=

    def initialize(*, publisher: nil)
      super(*)

      @publisher = publisher
    end

    before_save do
      collectivity.publisher = @publisher if @publisher
    end
  end
end
