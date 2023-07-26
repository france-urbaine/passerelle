# frozen_string_literal: true

module Admin
  module Offices
    class CommunePolicy < ::CommunePolicy
      alias_rule :edit_all?, :update_all?, to: :manage?
      alias_rule :remove_all?, :destroy_all?, to: :manage?

      def manage?
        super_admin?
      end
    end
  end
end
