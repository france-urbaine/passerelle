# frozen_string_literal: true

module Publishers
  class CollectivityPolicy < ApplicationPolicy
    alias_rule :new?, :create?, to: :index?
    alias_rule :remove_all?, :destroy_all?, :undiscard_all?, to: :index?

    def index?
      super_admin?
    end

    relation_scope do |relation|
      if super_admin?
        relation.kept
      else
        relation.none
      end
    end

    relation_scope :destroyable do |relation, exclude_current: true|
      relation = authorized(relation)
      relation = relation.where.not(id: organization) if collectivity? && exclude_current
      relation
    end

    relation_scope :undiscardable do |relation|
      relation = authorized(relation)
      relation.with_discarded.discarded
    end

    params_filter do |params|
      if super_admin?
        params.permit(
          :territory_type, :territory_id, :territory_data, :territory_code,
          :name, :siren,
          :contact_first_name, :contact_last_name, :contact_email, :contact_phone,
          :allow_2fa_via_email
        )
      end
    end
  end
end
