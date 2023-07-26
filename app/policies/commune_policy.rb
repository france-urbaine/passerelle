# frozen_string_literal: true

class CommunePolicy < ApplicationPolicy
  alias_rule :index?, :show?, to: :manage?

  def manage?
    super_admin?
  end

  relation_scope do |relation|
    relation
  end
end
