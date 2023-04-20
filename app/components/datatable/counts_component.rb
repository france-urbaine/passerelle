# frozen_string_literal: true

module Datatable
  class CountsComponent < ViewComponent::Base
    def initialize(datatable)
      @datatable = datatable
      super()
    end
  end
end
