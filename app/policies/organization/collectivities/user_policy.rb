# frozen_string_literal: true

module Organization
  module Collectivities
    class UserPolicy < ApplicationPolicy
      authorize :collectivity, optional: true

      alias_rule :index?, :new?, :create?, to: :manage?
      alias_rule :remove_all?, :destroy_all?, :undiscard_all?, to: :manage?

      def manage?
        if record == User
          publisher? && (
            collectivity.nil? ||
            allowed_to?(:manage?, collectivity, with: Organization::CollectivityPolicy)
          )
        elsif record.is_a? User
          publisher? &&
            publisher_of_user_collectivity?(record) &&
            allowed_to?(:manage?, collectivity, with: Organization::CollectivityPolicy)
        end
      end

      def reset?
        can_reset = manage?
        can_reset &= user != record if record.is_a?(User)
        can_reset
      end

      relation_scope do |relation|
        if publisher? && collectivity && allowed_to?(:manage?, collectivity, with: Organization::CollectivityPolicy)
          relation.kept.owned_by(collectivity)
        else
          relation.none
        end
      end

      relation_scope :destroyable do |relation, exclude_current: true|
        relation = authorized(relation, with: self.class)
        relation = relation.where.not(id: user) if exclude_current
        relation
      end

      relation_scope :undiscardable do |relation|
        relation = authorized(relation, with: self.class)
        relation.with_discarded.discarded
      end

      params_filter do |params|
        return unless publisher?

        attributes = %i[first_name last_name email]
        attributes << :organization_admin if organization_admin?
        attributes << :super_admin        if super_admin?

        params.permit(*attributes)
      end

      private

      def publisher_of_user_collectivity?(user)
        collectivity &&
          user.organization == collectivity &&
          user.organization.publisher_id == organization.id &&
          user.organization.allow_publisher_management?
      end
    end
  end
end
