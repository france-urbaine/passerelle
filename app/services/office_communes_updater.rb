# frozen_string_literal: true

class OfficeCommunesUpdater
  def initialize(office)
    @office = office
  end

  def update(commune_codes)
    new_commune_codes = extract_commune_codes_from_input(commune_codes)
    codes_to_delete   = previous_commune_codes - new_commune_codes
    codes_to_insert   = new_commune_codes - previous_commune_codes

    delete_commune_codes(codes_to_delete) if codes_to_delete.any?
    insert_commune_codes(codes_to_insert) if codes_to_insert.any?

    true
  end

  protected

  def extract_commune_codes_from_input(codes)
    @office.departement_communes
      .where(code_insee: codes)
      .pluck(:code_insee)
  end

  def previous_commune_codes
    @previous_commune_codes ||= @office.office_communes
      .pluck(:code_insee)
  end

  def delete_commune_codes(codes)
    OfficeCommune.where(
      office_id: @office.id,
      code_insee: codes
    ).delete_all
  end

  def insert_commune_codes(codes)
    input = codes.map do |value|
      {
        office_id: @office.id,
        code_insee: value
      }
    end

    OfficeCommune.insert_all(input)
  end
end
