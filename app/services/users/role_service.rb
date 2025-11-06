# frozen_string_literal: true

module Users
  class RoleService
    attr_reader :user, :organization

    def initialize(user, organization: nil)
      @user         = user
      @organization = organization
    end

    def viewer_type
      @viewer_type ||= case user_role
                       when :publisher                then :collectivity
                       when :dgfip, :ddfip_form_admin then :ddfip_admin
                       else user_role
                       end
    end

    def user_role
      @user_role ||= case organization_type
                     when "publisher"    then :publisher
                     when "collectivity" then :collectivity
                     when "dgfip"        then :dgfip
                     when "ddfip"        then ddfip_role
                     end
    end

    private

    def organization_type
      @organization_type ||= case organization
                             in Symbol then organization.to_s
                             in String then organization
                             in ApplicationRecord then organization.model_name.element
                             else user.organization_type&.to_s&.underscore
                             end
    end

    def ddfip_role
      if user&.organization_admin?
        :ddfip_admin
      elsif user&.form_admin?
        :ddfip_form_admin
      else
        :ddfip_user
      end
    end
  end
end
