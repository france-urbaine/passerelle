# frozen_string_literal: true

class TransmissionPolicy < ApplicationPolicy
  def show?
    user? && collectivity?
  end

  def create?
    if record.is_a?(Report)
      user? && collectivity? && record.transmissible?
    else
      user? && collectivity?
    end
  end

  def completed?
    user? && collectivity?
  end

  def manage?
    user? && collectivity?
  end
end
