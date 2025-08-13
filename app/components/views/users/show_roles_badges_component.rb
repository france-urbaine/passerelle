# frozen_string_literal: true

module Views
  module Users
    class ShowRolesBadgesComponent < ApplicationViewComponent
      def initialize(user)
        @user = user
        super()
      end

      def display_role_warning?
        @user.organization_type == "DDFIP" &&
          !@user.super_admin? &&
          !@user.organization_admin? &&
          @user.offices.empty?
      end

      def supervised_office_ids
        @user.office_users.filter_map { it.office_id if it.supervisor? }
      end
    end
  end
end
