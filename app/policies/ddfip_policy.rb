# frozen_string_literal: true

class DDFIPPolicy < ApplicationPolicy
  alias_rule :index?, :create?, :manage_collection?, to: :manage?

  def manage?
    super_admin?
  end

  relation_scope do |relation|
    if super_admin?
      relation
    else
      relation.none
    end
  end

  params_filter do |params|
    if super_admin?
      params.permit(
        :name, :code_departement,
        :contact_first_name, :contact_last_name, :contact_email, :contact_phone
      )
    end
  end
end
