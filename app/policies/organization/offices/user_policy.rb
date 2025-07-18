# frozen_string_literal: true

module Organization
  module Offices
    class UserPolicy < Organization::UserPolicy
      authorize :office, optional: true

      alias_rule :show?, :edit?, :update?, :undiscard?, :undiscard_all?, to: :not_supported?
      alias_rule :index?, :new?, :create?, to: :manage?
      alias_rule :remove_all?, :destroy_all?, to: :manage?
      alias_rule :remove?, :destroy?, to: :manage?
      alias_rule :edit_all?, :update_all?, to: :manage?

      def manage?
        if record == User
          ddfip_admin? || supervisor_of_office?
        elsif record.is_a? User
          organization_match?(record) &&
            (ddfip_admin? || (supervisor_of_office? && supervisor_of?(record)))
        end
      end

      private

      def supervisor_of_office?
        supervisor? && (office.nil? || supervisor_of?(office))
      end
    end
  end
end
