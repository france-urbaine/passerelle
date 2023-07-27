# frozen_string_literal: true

module Views
  module Users
    class FormComponent < ApplicationViewComponent
      def initialize(user, scope:, organization: nil, redirection_path: nil)
        @user             = user
        @organization     = organization
        @scope            = scope
        @redirection_path = redirection_path
        super()
      end

      def redirection_path
        if @redirection_path.nil? && @user.errors.any? && params[:redirect]
          params[:redirect]
        else
          @redirection_path
        end
      end

      def form_url
        url_args = [@scope]

        if @user.new_record?
          url_args << @organization
          url_args << :users
        elsif @scope == :organization
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
        @scope == :admin && @organization.nil?
      end

      def allowed_to_assign_offices?
        (@scope == :admin && @organization.nil?) ||
          (@scope == :admin && @organization.is_a?(DDFIP)) ||
          (@scope == :organization && current_organization.is_a?(DDFIP))
      end

      def allowed_to_assign_organization_admin?
        @scope == :admin || (@scope == :organization && current_user.organization_admin?)
      end

      def allowed_to_assign_super_admin?
        @scope == :admin || (@scope == :organization && current_user.super_admin?)
      end

      def organization_input_html_attributes
        {
          value:       organization_name,
          placeholder: "Commnencez à taper pour sélectionner une organisation",
          data:        { autocomplete_target: "input" }
        }
      end

      def organization_hidden_html_attributes
        if @user.organization
          organization_data = {
            type: @user.organization_type,
            id:   @user.organization_id
          }.to_json
        end

        {
          value: organization_data,
          data: {
            autocomplete_target: "hidden",
            action:              "user-form#updateServices"
          }
        }
      end

      def organization_name
        @user.organization&.name
      end

      def organization_type_choice
        [
          Publisher,
          DDFIP,
          Collectivity
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
