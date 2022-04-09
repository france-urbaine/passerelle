# frozen_string_literal: true

require "rails_helper"

RSpec.describe EPCI, type: :model do
  # Associations
  # ----------------------------------------------------------------------------
  it { is_expected.to belong_to(:departement).optional }
  it { is_expected.to have_many(:communes) }
  it { is_expected.to have_many(:collectivities) }

  # Validations
  # ----------------------------------------------------------------------------
  it { is_expected.to     validate_presence_of(:name) }
  it { is_expected.to     validate_presence_of(:siren) }
  it { is_expected.not_to validate_presence_of(:code_departement) }

  it { is_expected.to     allow_value("801453893").for(:siren) }
  it { is_expected.not_to allow_value("1234567AB").for(:siren) }
  it { is_expected.not_to allow_value("1234567891").for(:siren) }

  it { is_expected.to     allow_value("01").for(:code_departement) }
  it { is_expected.to     allow_value("2A").for(:code_departement) }
  it { is_expected.to     allow_value("987").for(:code_departement) }
  it { is_expected.not_to allow_value("1").for(:code_departement) }
  it { is_expected.not_to allow_value("123").for(:code_departement) }
  it { is_expected.not_to allow_value("3C").for(:code_departement) }
end
