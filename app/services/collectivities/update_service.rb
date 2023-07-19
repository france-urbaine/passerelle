# frozen_string_literal: true

module Collectivities
  class UpdateService < FormService
    alias_record :collectivity

    attr_reader :territory_data
    attr_accessor :territory_code

    before_validation do
      apply_territory_data if territory_data
      apply_territory_code if territory_code
    end

    def territory_data=(value)
      @territory_data = JSON.parse(value)
    rescue TypeError, JSON::ParserError
      @territory_data = {} # :nocov:
    end

    private

    def apply_territory_data
      collectivity.territory_type = territory_data["type"]
      collectivity.territory_id   = territory_data["id"]
    end

    def apply_territory_code
      collectivity.territory_id = find_territory_id_from_code(territory_code)
    end

    def find_territory_id_from_code(value)
      return if value.blank?

      case collectivity.territory_type
      when "Commune"     then Commune.where(code_insee: value).pick(:id)
      when "EPCI"        then EPCI.where(siren: value).pick(:id)
      when "Departement" then Departement.where(code_departement: value).pick(:id)
      when "Region"      then Region.where(code_region: value).pick(:id)
      end
    end
  end
end
