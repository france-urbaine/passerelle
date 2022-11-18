# frozen_string_literal: true

require "rails_helper"

RSpec.describe ServiceCommune do
  # Associations
  # ----------------------------------------------------------------------------
  it { is_expected.to belong_to(:service).required }
  it { is_expected.to belong_to(:commune).optional }
end
