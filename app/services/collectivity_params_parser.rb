# frozen_string_literal: true

# CollectivityParamsParser is a service to parse parameters passed to
# CollectivitiesController to create or update a collectivity.
#
# It accepts a hash with a :territory_type and :territory_code
# The code should be a unique identifier of the territory:
#   - Commune#code_insee
#   - EPCI#siren
#   - Departement#code_departement
#   - Region#codre_region
#
#   CollectivityParamsParser.new(
#     territory_type: "Commune",
#     territory_code: "64102"
#   })
#
# It also accepts a JSONified key :territory_data:
#
#   CollectivityParamsParser.new({
#     territory_data: '{"type":"Commune","id": "4d1808e4-d46d-4904-a900-dc183cfc26fb"}'
#   }).parse
#
# As a result, it'll return the :territory_type and territory_id required to
# assign a territory to a Collectivity:
#
#   > CollectivityParamsParser.new(input).parse
#   { territory_type: "Commune", territory_id: "4d1808e4-d46d-4904-a900-dc183cfc26fb" }
#
class CollectivityParamsParser
  def initialize(input, publisher = nil)
    @input     = input.dup
    @publisher = publisher
  end

  def parse
    @input.delete(:publisher_id) if @publisher

    parse_territory_data
    parse_territory_code
    @input
  end

  protected

  def parse_territory_data
    territory_data = @input.delete(:territory_data)
    return if territory_data.blank?

    territory_data = JSON.parse(territory_data)
    @input[:territory_type] = territory_data["type"]
    @input[:territory_id]   = territory_data["id"]
  end

  def parse_territory_code
    territory_code = @input.delete(:territory_code)
    territory_type = @input[:territory_type]
    return if territory_code.blank?

    @input[:territory_id] =
      case territory_type
      when "Commune"     then Commune.where(code_insee: territory_code).pick(:id)
      when "EPCI"        then EPCI.where(siren: territory_code).pick(:id)
      when "Departement" then Departement.where(code_departement: territory_code).pick(:id)
      when "Region"      then Region.where(code_region: territory_code).pick(:id)
      end
  end
end
