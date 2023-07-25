# frozen_string_literal: true

module Users
  class UpdateService < FormService
    alias_record :user

    attr_reader :organization_data
    attr_accessor :organization_name, :office_ids

    before_validation do
      apply_organization_data if organization_data
      apply_organization_name if organization_name
    end

    before_save do
      update_office_ids
    end

    def organization_data=(value)
      @organization_data = JSON.parse(value)
    rescue TypeError, JSON::ParserError
      @organization_data = {}
    end

    private

    def apply_organization_data
      user.organization_type = organization_data["type"]
      user.organization_id   = organization_data["id"]
    end

    def apply_organization_name
      user.organization_id = find_organization_id_from_name(organization_name)
    end

    def find_organization_id_from_name(value)
      return if value.blank?

      case user.organization_type
      when "DDFIP"        then DDFIP.kept.search(name: value).pick(:id)
      when "Publisher"    then Publisher.kept.search(name: value).pick(:id)
      when "Collectivity" then Collectivity.kept.search(name: value).pick(:id)
      end
    end

    def update_office_ids
      return unless defined?(@office_ids) || user.will_save_change_to_organization_id?

      if user.organization.is_a?(DDFIP)
        office_ids           = defined?(@office_ids) ? Array.wrap(@office_ids) : user.office_ids
        organization_offices = user.organization.offices.kept

        user.office_ids = organization_offices.where(id: office_ids).ids
      else
        user.office_ids = []
      end
    end
  end
end
