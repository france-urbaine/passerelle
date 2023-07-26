# frozen_string_literal: true

module Organization
  module Offices
    class UserPolicy < Organization::UserPolicy
      alias_rule :index?, :new?, :create?, to: :manage?
      alias_rule :remove_all?, :destroy_all?, to: :manage?
      alias_rule :edit_all?, :update_all?, to: :manage?

      def manage?
        if record == User
          ddfip_admin?
        elsif record.is_a? User
          ddfip_admin? && organization_match?(record)
        end
      end

      alias_rule :show?, :edit?, :update?, :undiscard?, :undiscard_all?, to: :not_supported

      def not_supported
        false
      end
    end
  end
end
