# frozen_string_literal: true

class TransmissionPolicy < ApplicationPolicy
  alias_rule :show?, :create?, :remove?, :complete?, to: :manage?

  def manage?
    collectivity?
  end
end
