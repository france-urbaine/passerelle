# frozen_string_literal: true

module Views
  module Users
    class ShowFormTypesListComponent < ApplicationViewComponent
      def initialize(user, namespace:)
        @user      = user
        @namespace = namespace
        super()
      end

      def call
        return if @user.organization_admin?

        helpers.list(user_form_types) do |user_form_type|
          I18n.t(user_form_type.form_type, scope: "enum.report_form_type", default: "")
        end
      end

      def user_form_types
        @user_form_types ||= @user.user_form_types.to_a.sort_by!(&:form_type)
      end
    end
  end
end
