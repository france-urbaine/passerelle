# frozen_string_literal: true

module Organization
  module Offices
    class CommunePolicy < ApplicationPolicy
      alias_rule :new?, :create?, :show?, :edit?, :update?, :undiscard?, :undiscard_all?, to: :not_supported?
      alias_rule :index?, :edit_all?, :update_all?, to: :manage?
      alias_rule :remove_all?, :destroy_all?, to: :manage?

      def manage?
        ddfip_admin?
      end

      relation_scope do |relation|
        relation
      end
    end
  end
end
