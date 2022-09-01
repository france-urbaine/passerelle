# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Service, type: :model do
  # Associations
  # ----------------------------------------------------------------------------
  it { is_expected.to belong_to(:ddfip).required }

  it { is_expected.to have_many(:user_services) }
  it { is_expected.to have_many(:users).through(:user_services) }

  it { is_expected.to have_many(:service_communes) }
  it { is_expected.to have_many(:communes).through(:service_communes) }

  # Validations
  # ----------------------------------------------------------------------------
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:action) }

  it do
    is_expected.to validate_inclusion_of(:action)
      .in_array(%w[evaluation_hab evaluation_eco occupation_hab occupation_eco])
  end
end
