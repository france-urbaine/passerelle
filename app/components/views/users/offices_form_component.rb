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

      def enabled_offices
        @enabled_offices ||=
          if allowed_to_assign_offices? && (current_user.organization_admin || current_user.super_admin)
            offices.pluck(:id)
          elsif allowed_to_assign_offices?
            current_user.office_users.where(supervisor: true).pluck(:office_id)
          else
            []
          end
      end

      def checked_offices
        @checked_offices ||= @user.office_users.map(&:office_id)
      end

      def office_users
        @office_users ||= begin
          office_users = @user.office_users
          office_users += offices.filter_map do |office|
            OfficeUser.new(user: @user, office: office) unless office.id.in?(checked_offices)
          end
          office_users.sort_by do |office_user|
            [!office_user.office_id.in?(enabled_offices), office_user.office.name].join
          end
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
