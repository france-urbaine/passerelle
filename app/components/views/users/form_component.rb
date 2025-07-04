# frozen_string_literal: true

module Views
  module Users
    class FormComponent < ApplicationViewComponent
      def initialize(user, namespace:, organization: nil, referrer: nil)
        @user         = user
        @namespace    = namespace
        @organization = organization
        @referrer     = referrer
        super()
      end

      def redirection_path
        if @referrer.nil? && @user.errors.any? && params[:redirect]
          params[:redirect]
        else
          @referrer
        end
      end

      def form_url
        url_args = [@namespace]

        if @user.new_record?
          url_args << @organization
          url_args << :users
        elsif @namespace == :organization
          url_args << @organization
          url_args << @user
        else
          url_args << @user
        end

        polymorphic_path(url_args.compact)
      end

      def form_html_attributes
        return {} unless allowed_to_assign_offices? && allowed_to_assign_organization?

        # In admin, we can change the organization of an user
        # Therefore, we need to update the offices accordingly to the  selected organization
        #
        {
          data: {
            controller: "user-form",
            user_form_offices_url_value: admin_users_offices_path(user_id: @user.id)
          }
        }
      end

      def allowed_to_assign_organization?
        @namespace == :admin && @organization.nil?
      end

      def allowed_to_assign_offices?
        (@namespace == :admin && @organization.nil?) ||
          (@namespace == :admin && @organization.is_a?(DDFIP)) ||
          (@namespace == :organization && current_organization.is_a?(DDFIP))
      end

      def allowed_to_assign_organization_admin?
        @namespace == :admin || (@namespace == :organization && current_user.organization_admin?)
      end

      def allowed_to_assign_super_admin?
        @namespace == :admin
      end

      def organization_search_options
        {
          value:       organization_name,
          placeholder: "Commencez à taper pour sélectionner une organisation"
        }
      end

      def organization_hidden_options
        if @user.organization
          organization_data = {
            type: @user.organization_type,
            id:   @user.organization_id
          }
        end

        {
          value: organization_data,
          data: { action: "user-form#updateServices" }
        }
      end

      def organization_name
        @user.organization&.name
      end

      def organization_type_choice
        [
          Publisher,
          DDFIP,
          Collectivity,
          DGFIP
        ].map { |m| [m.model_name.human, m.name] }
      end

      def office_ids_choices
        return [] unless allowed_to_assign_offices?

        ddfip = @organization || current_organization
        ddfip.offices.kept.strict_loading.to_a
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
