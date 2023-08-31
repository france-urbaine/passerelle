# frozen_string_literal: true

module PriorityIcon
  class Component < ApplicationViewComponent
    def initialize(priority)
      @priority = priority
    end

    def call
      case @priority.to_s
      when "low"    then icon_component("priority", "Basse",   class: "low-priority-icon")
      when "medium" then icon_component("priority", "Moyenne", class: "medium-priority-icon")
      when "high"   then icon_component("priority", "Haute",   class: "high-priority-icon")
      end
    end
  end
end