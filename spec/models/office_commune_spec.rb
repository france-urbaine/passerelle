# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfficeCommune do
  # Associations
  # ----------------------------------------------------------------------------
  it { is_expected.to belong_to(:office).required }
  it { is_expected.to belong_to(:commune).optional }
end
