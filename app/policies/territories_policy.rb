# frozen_string_literal: true

class TerritoriesPolicy < ApplicationPolicy
  authorize :user, allow_nil: true

  def index?
    true
  end

  def manage?
    user.present? && user.super_admin?
  end
end