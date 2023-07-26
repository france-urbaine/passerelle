# frozen_string_literal: true

module Organization
  module Collectivities
    class UserPolicy < ApplicationPolicy
      alias_rule :index?, :new?, :create?, to: :manage?
      alias_rule :remove_all?, :destroy_all?, :undiscard_all?, to: :manage?

      def manage?
        if record == User
          publisher?
        elsif record.is_a? User
          publisher? && publisher_of_user_collectivity?(record)

        end
      end

      relation_scope do |relation|
        if publisher?
          relation.kept.owned_by(organization.collectivities)
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
        user.organization.is_a?(Collectivity) &&
          user.organization.publisher_id == organization.id
      end
    end
  end
end
