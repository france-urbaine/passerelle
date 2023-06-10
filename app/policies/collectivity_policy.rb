# frozen_string_literal: true

class CollectivityPolicy < ApplicationPolicy
  alias_rule :new?, :create?, to: :index?
  alias_rule :remove_all?, :destroy_all?, :undiscard_all?, to: :index?

  def index?
    super_admin? || publisher?
  end

  def manage?
    super_admin? ||
      (record == Collectivity && publisher?) ||
      (record.is_a?(Collectivity) && publisher? && record.publisher_id == organization.id)
  end

  def assign_publisher?
    super_admin?
  end

  relation_scope do |relation|
    if super_admin?
      relation
    elsif publisher?
      relation.owned_by(organization)
    else
      relation.none
    end
  end

  params_filter do |params|
    if super_admin?
      params.permit(
        :publisher_id,
        :territory_type, :territory_id, :territory_data, :territory_code,
        :name, :siren,
        :contact_first_name, :contact_last_name, :contact_email, :contact_phone,
        :allow_2fa_via_email
      )
    elsif publisher?
      params.permit(
        :territory_type, :territory_id, :territory_data, :territory_code,
        :name, :siren,
        :contact_first_name, :contact_last_name, :contact_email, :contact_phone,
        :allow_2fa_via_email
      )
    else
      {}
    end
  end
end
