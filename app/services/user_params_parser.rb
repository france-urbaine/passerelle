# frozen_string_literal: true

# UserParamsParser is a office to parse parameters passed to
# UsersController to create or update an user.
#
class UserParamsParser
  def initialize(input)
    @input = input.dup
  end

  def parse
    @input.delete(:organization)

    extract_organization_data
    extract_organization_name
    extract_office_ids

    @input
  end

  protected

  def extract_organization_data
    organization_data = @input.delete(:organization_data)
    return if organization_data.blank?

    organization_data          = JSON.parse(organization_data)
    @input[:organization_type] = organization_data["type"]
    @input[:organization_id]   = organization_data["id"]
  end

  def extract_organization_name
    organization_name = @input.delete(:organization_name)
    organization_type = @input[:organization_type]
    return if organization_name.blank?

    @input[:organization_id] =
      case organization_type
      when "Publisher"    then Publisher.kept.search(name: organization_name).pick(:id)
      when "DDFIP"        then DDFIP.kept.search(name: organization_name).pick(:id)
      when "Collectivity" then Collectivity.kept.search(name: organization_name).pick(:id)
      end
  end

  def extract_office_ids
    office_ids = @input.delete(:office_ids)
    organization_id = @input[:organization_id]
    organization_type = @input[:organization_type]
    return if office_ids.blank? || organization_type != "DDFIP"

    @input[:office_ids] = Office.kept.where(
      id:       office_ids,
      ddfip_id: organization_id
    ).pluck(:id)
  end
end
