# frozen_string_literal: true

module Organization
  module Offices
    class CommunePolicy < ::CommunePolicy
      alias_rule :edit_all?, :update_all?, to: :manage?
      alias_rule :remove_all?, :destroy_all?, to: :manage?

      def manage?
        ddfip_admin?
      end

      alias_rule :new?, :create?, :show?, :edit?, :update?, :undiscard?, :undiscard_all?, to: :not_supported

      def not_supported
        false
      end
    end
  end
end
