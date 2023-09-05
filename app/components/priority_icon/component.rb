# frozen_string_literal: true

module PriorityIcon
  class Component < ApplicationViewComponent
    def initialize(priority)
      @priority = priority
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
