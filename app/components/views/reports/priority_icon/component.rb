# frozen_string_literal: true

module Views
  module Reports
    module PriorityIcon
      class Component < ApplicationViewComponent
        def initialize(arg)
          @priority =
            case arg
            when Report then arg.priority.to_sym
            when Symbol then arg
            else raise TypeError, "invalid argument: #{arg.inspect}"
            end

          super()
        end

        def call
          case @priority.to_s
          when "low"    then icon_component("priority", "Priorité basse",   class: "low-priority-icon")
          when "medium" then icon_component("priority", "Priorité moyenne", class: "medium-priority-icon")
          when "high"   then icon_component("priority", "Priorité haute",   class: "high-priority-icon")
          end
        end
      end
    end
  end
end
