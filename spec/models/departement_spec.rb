# frozen_string_literal: true

require "rails_helper"

RSpec.describe Departement, type: :model do
  # Associations
  # ----------------------------------------------------------------------------
  it { is_expected.to have_many(:communes) }
  it { is_expected.to have_many(:epcis) }
  it { is_expected.to have_many(:ddfips) }
  it { is_expected.to have_many(:collectivities) }

  # Validations
  # ----------------------------------------------------------------------------
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:code_departement) }
  it { is_expected.to validate_presence_of(:code_region) }

  it { is_expected.to     allow_value("01") .for(:code_departement) }
  it { is_expected.to     allow_value("2A") .for(:code_departement) }
  it { is_expected.to     allow_value("987").for(:code_departement) }
  it { is_expected.not_to allow_value("1")  .for(:code_departement) }
  it { is_expected.not_to allow_value("123").for(:code_departement) }
  it { is_expected.not_to allow_value("3C") .for(:code_departement) }

  it { is_expected.to     allow_value("12")  .for(:code_region) }
  it { is_expected.not_to allow_value("12AB").for(:code_region) }
end
