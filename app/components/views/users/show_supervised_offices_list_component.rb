# frozen_string_literal: true

module Views
  module Users
    class ShowSupervisedOfficesListComponent < ApplicationViewComponent
      def initialize(user, namespace:)
        @user      = user
        @namespace = namespace
        super()
      end

      def call
        return if offices.empty?

        helpers.list(offices) do |office|
          authorized_link_to(office, namespace: @namespace)
        end
      end

      def offices
        @offices ||= begin
          offices = @user.offices.select do |office|
            office.kept? && office.ddfip_id == @user.organization_id &&
              office.id.in?(supervised_office_ids)
          end

          # Add a consistent & deterministic order
          offices.sort_by!(&:name)
          offices
        end
      end

      def supervised_office_ids
        @user.office_users.filter_map { _1.office_id if _1.supervisor? }
      end
    end
  end
end
