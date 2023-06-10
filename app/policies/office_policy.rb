# frozen_string_literal: true

class OfficePolicy < ApplicationPolicy
  alias_rule :new?, :create?, to: :index?
  alias_rule :remove_all?, :destroy_all?, :undiscard_all?, to: :index?

  def index?
    super_admin? || ddfip_admin?
  end

  def manage?
    super_admin? ||
      (record == Office && ddfip_admin?) ||
      (record.is_a?(Office) && ddfip_admin? && record.ddfip_id == organization.id)
  end

  relation_scope do |relation|
    if super_admin?
      relation
    elsif ddfip_admin?
      relation.owned_by(organization)
    else
      relation.none
    end
  end

  params_filter do |params|
    if super_admin?
      params.permit(:ddfip_name, :ddfip_id, :name, :action)
    elsif ddfip_admin?
      params.permit(:name, :action)
    end
  end
end
