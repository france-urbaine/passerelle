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

      def form_url
        url_args = [@scope]

        if @user.new_record?
          url_args << @organization
          url_args << :users
        else
          url_args << @user
        end

        polymorphic_path(url_args.compact)
      end

      def allowed_to_assign_organization?
        @scope == :admin && @organization.nil?
      end

      def allowed_to_assign_offices?
        @scope == :organization && current_organization.is_a?(DDFIP)
      end

      def allowed_to_assign_organization_admin?
        @scope == :admin ||
          (@scope == :organization && current_user.organization_admin?)
      end

      def allowed_to_assign_super_admin?
        @scope == :admin ||
          (@scope == :organization && current_user.super_admin?)
      end

      def organization_input_html_attributes
        {
          value:       organization_name,
          placeholder: "Commnencez à taper pour sélectionner des organisations",
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

        current_organization.offices.kept.strict_loading.to_a
      end
    end
  end
end
