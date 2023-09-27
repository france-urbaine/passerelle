# frozen_string_literal: true

class TransmissionPolicy < ApplicationPolicy
  def show?
    true
  end

  def create?
    true
  end

  def completed?
    true
  end

  def manage?
    true
  end
end
