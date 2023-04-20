# frozen_string_literal: true

module Datatable
  class SelectionComponent < ViewComponent::Base
    renders_many :actions, "Action"

    attr_reader :label

    def initialize(label = nil)
      @label = label
      super()
    end

    def call
    end

    class Action < ::ButtonComponent
      def href_params
        p params.slice(:ids, :search, :order, :page).permit!

        super.merge(
          params.slice(:ids, :search, :order, :page).permit!
        )
      end
    end
  end
end
