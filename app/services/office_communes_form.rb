# frozen_string_literal: true

class OfficeCommunesForm
  extend ActiveModel::Naming

  def initialize(office)
    @office = office
  end

  def model_name
    @model_name ||= ActiveModel::Name.new(self, nil, "OfficeCommunes")
  end

  def suggested_communes
    @suggested_communes ||= @office.departement_communes.order(:code_insee)
  end

  def suggested_epcis
    @suggested_epcis ||= EPCI.having_communes(suggested_communes).order(:name)
  end

  def commune_codes
    @commune_codes ||= @office.office_communes.pluck(:code_insee)
  end

  def epci_codes
    @epci_codes ||= EPCI.having_communes(@office.communes).pluck(:siren)
  end
end
