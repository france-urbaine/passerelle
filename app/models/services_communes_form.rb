# frozen_string_literal: true

class ServicesCommunesForm
  include ActiveModel::Model

  attr_reader :service

  def initialize(service)
    @service = service
  end

  def departement_communes
    @departement_communes ||= @service.ddfip.departement.communes
  end

  def departement_epcis
    @departement_epcis ||= EPCI.having_communes(departement_communes)
  end

  def codes_insee
    @codes_insee ||= service.service_communes.pluck(:code_insee)
  end

  def epci_sirens
    @epci_sirens ||= EPCI.having_communes(service.communes).pluck(:siren)
  end

  def update(new_codes_insee)
    old_codes_insee = codes_insee
    new_codes_insee = departement_communes
      .where(code_insee: new_codes_insee.uniq)
      .pluck(:code_insee)

    codes_to_delete = old_codes_insee - new_codes_insee
    if codes_to_delete.any?
      ServiceCommune.where(
        service_id: service.id,
        code_insee: codes_to_delete
      ).delete_all
    end

    codes_to_insert = new_codes_insee - old_codes_insee
    if codes_to_insert.any?
      insert_data = codes_to_insert.map do |value|
        {
          service_id: service.id,
          code_insee: value
        }
      end

      ServiceCommune.insert_all(insert_data)
    end

    true
  end
end
