# frozen_string_literal: true

module Organization
  class OauthApplicationPolicy < ApplicationPolicy
    alias_rule :index?, :new?, :create?, :show?, to: :manage?
    alias_rule :remove_all?, :destroy_all?, :undiscard_all?, to: :manage?

    def manage?
      if record == OauthApplication
        publisher?
      elsif record.is_a?(OauthApplication)
        publisher? && record.owner == organization
      end
    end

    relation_scope do |relation|
      if publisher?
        relation.kept.owned_by(organization)
      else
        relation.none
      end
    end

    relation_scope :destroyable do |relation|
      authorized(relation, with: self.class)
    end

    relation_scope :undiscardable do |relation|
      relation = authorized(relation, with: self.class)
      relation.with_discarded.discarded
    end

    params_filter do |params|
      return unless publisher?

      params.permit(:name, :sandbox)
    end
  end
end
