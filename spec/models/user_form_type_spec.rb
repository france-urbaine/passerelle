# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserFormType do
  # Associations
  # ----------------------------------------------------------------------------
  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  # Validations
  # ----------------------------------------------------------------------------
  describe "validations" do
    it { is_expected.to validate_presence_of(:form_type) }

    it { is_expected.to validate_inclusion_of(:form_type).in_array(Report::FORM_TYPES) }
  end
end
