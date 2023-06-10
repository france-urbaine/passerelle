# frozen_string_literal: true

class PublisherPolicy < ApplicationPolicy
  alias_rule :index?, :new?, :create?, to: :manage?
  alias_rule :remove_all?, :destroy_all?, :undiscard_all?, to: :manage?

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
        :name, :siren,
        :contact_first_name, :contact_last_name, :contact_email, :contact_phone,
        :allow_2fa_via_email
      )
    end
  end
end
