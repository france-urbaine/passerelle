# frozen_string_literal: true

require "rails_helper"

RSpec.describe Commune, type: :model do
  # Associations
  # ----------------------------------------------------------------------------
  it { is_expected.to belong_to(:departement).required }
  it { is_expected.to belong_to(:epci).optional }
  it { is_expected.to have_many(:collectivities) }

  # Validations
  # ----------------------------------------------------------------------------
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:code_insee) }
  it { is_expected.to validate_presence_of(:code_departement) }
  it { is_expected.not_to validate_presence_of(:siren_epci) }

  it { is_expected.to     allow_value("64102").for(:code_insee) }
  it { is_expected.to     allow_value("2A013").for(:code_insee) }
  it { is_expected.to     allow_value("97102").for(:code_insee) }
  it { is_expected.not_to allow_value("1A674").for(:code_insee) }
  it { is_expected.not_to allow_value("123456").for(:code_insee) }

  it { is_expected.to     allow_value("01").for(:code_departement) }
  it { is_expected.to     allow_value("2A").for(:code_departement) }
  it { is_expected.to     allow_value("987").for(:code_departement) }
  it { is_expected.not_to allow_value("1").for(:code_departement) }
  it { is_expected.not_to allow_value("123").for(:code_departement) }
  it { is_expected.not_to allow_value("3C").for(:code_departement) }

  it { is_expected.to     allow_value("801453893").for(:siren_epci) }
  it { is_expected.not_to allow_value("1234567AB").for(:siren_epci) }
  it { is_expected.not_to allow_value("1234567891").for(:siren_epci) }

  # Formatting before save
  # ----------------------------------------------------------------------------
  it { expect(create(:commune, siren_epci: "")).to have_attributes(siren_epci: nil) }
end
