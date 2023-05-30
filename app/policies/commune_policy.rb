# frozen_string_literal: true

class CommunePolicy < ApplicationPolicy
  alias_rule :index?, :show?, to: :manage?

  def manage?
    super_admin?
  end
end
