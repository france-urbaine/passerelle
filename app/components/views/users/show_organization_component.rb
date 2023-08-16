# frozen_string_literal: true

module Views
  module Users
    class ShowOrganizationComponent < ApplicationViewComponent
      def initialize(user, namespace: :admin)
        @user      = user
        @namespace = namespace
        super()
      end

      def call
        if @user.organization&.kept?
          authorized_link_to @user.organization, scope: @namespace do
            @user.organization.name
          end
        elsif @user.organization&.discarded?
          tag.div(class: "text-disabled") do
            concat @user.organization.name
            concat " (organisation supprimée)"
          end
        end
      end
    end
  end
end
