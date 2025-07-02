# frozen_string_literal: true

module Views
  module Users
    class OfficesFormComponent < ApplicationViewComponent
      def initialize(user, namespace:, organization: nil)
        @user         = user
        @namespace    = namespace
        @organization = organization
        super()
      end

      def allowed_to_assign_organization?
        @namespace == :admin && @organization.nil?
      end

      def allowed_to_assign_offices?
        (@namespace == :admin && @organization.nil?) ||
          (@namespace == :admin && @organization.is_a?(DDFIP)) ||
          (@namespace == :organization && current_organization.is_a?(DDFIP))
      end

      def offices
        @offices ||= if allowed_to_assign_offices?
                       ddfip = @organization || current_organization
                       ddfip.offices.kept.order(:name).strict_loading.to_a
                     else
                       []
                     end
      end

      def office_users
        @office_users = @user.office_users
        @office_users += offices.filter_map do |office|
          OfficeUser.new(user: @user, office: office) unless office.id.in?(@user.office_ids)
        end
      end

      def offices_block_html_attributes
        return {} unless allowed_to_assign_offices?

        attributes = { data: { user_form_target: "officesFormBlock" } }

        unless @user.organization.is_a?(DDFIP)
          attributes[:class] = "hidden"
          attributes[:hidden] = true
        end

        attributes
      end

      def offices_frame_html_attributes
        return {} unless allowed_to_assign_offices?

        attributes = { data: { user_form_target: "officesCheckboxesFrame" } }

        if @user.organization.is_a?(DDFIP)
          attributes[:src] = admin_users_offices_path(
            user_id:    @user.id,
            ddfip_id:   @user.organization_id,
            office_ids: @user.office_ids
          )
        end

        attributes
      end
    end
  end
end
