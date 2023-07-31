# frozen_string_literal: true

module Organization
  class CollectivityPolicy < ApplicationPolicy
    alias_rule :new?, :create?, to: :manage?
    alias_rule :remove_all?, :destroy_all?, :undiscard_all?, to: :manage?

    def index?
      # A DDFIP admin can list all collectivities assigned to its territory
      publisher? || ddfip_admin?
    end

    def show?
      if record == Collectivity
        publisher? || ddfip_admin?
      elsif record.is_a?(Collectivity)
        (
          publisher? && publisher_of_collectivity?(record)
        ) || (
          ddfip_admin? && ddfip_of_collectivity?(record)
        )
      end
    end

    def manage?
      if record == Collectivity
        publisher?
      elsif record.is_a?(Collectivity)
        publisher? && publisher_of_collectivity?(record) && record.allow_publisher_management?
      end
    end

    relation_scope do |relation|
      if publisher?
        relation.kept.owned_by(organization)
      elsif ddfip_admin?
        relation.kept.merge(organization.on_territory_collectivities)
      else
        relation.none
      end
    end

    relation_scope :destroyable do |relation, exclude_current: true|
      if publisher?
        relation = authorized(relation, with: self.class)
        relation = relation.where(allow_publisher_management: true)
        relation = relation.where.not(id: organization) if collectivity? && exclude_current
        relation
      else
        relation.none
      end
    end

    relation_scope :undiscardable do |relation|
      if publisher?
        relation = authorized(relation, with: self.class)
        relation = relation.where(allow_publisher_management: true)
        relation.with_discarded.discarded
      else
        relation.none
      end
    end

    params_filter do |params|
      return unless publisher?

      params.permit(
        :territory_type, :territory_id, :territory_data, :territory_code,
        :name, :siren,
        :contact_first_name, :contact_last_name, :contact_email, :contact_phone,
        :allow_2fa_via_email
      )
    end

    private

    def publisher_of_collectivity?(collectivity)
      collectivity.publisher_id == organization.id
    end

    def ddfip_of_collectivity?(collectivity)
      organization.on_territory_collectivities.include?(collectivity)
    end
  end
end
