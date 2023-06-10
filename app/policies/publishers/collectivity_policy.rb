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
        relation
      else
        relation.none
      end
    end

    params_filter do |params|
      if super_admin?
        params.permit(
          :territory_type, :territory_id, :territory_data, :territory_code,
          :name, :siren,
          :contact_first_name, :contact_last_name, :contact_email, :contact_phone
        )
      else
        {}
      end
    end
  end
end
