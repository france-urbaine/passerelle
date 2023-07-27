# frozen_string_literal: true

class TerritoriesPolicy < ApplicationPolicy
  def index?
    user?
  end
end
