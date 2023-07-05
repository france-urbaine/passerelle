# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReportExoneration do
  # Associations
  # ----------------------------------------------------------------------------
  describe "associations" do
    it { is_expected.to belong_to(:report).required }
  end

  # Validations
  # ----------------------------------------------------------------------------
  describe "validations" do
    it { is_expected.to validate_presence_of(:code) }
    it { is_expected.to validate_presence_of(:label) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:base) }
    it { is_expected.to validate_presence_of(:code_collectivite) }

    it { is_expected.to validate_inclusion_of(:status).in_array(ReportExoneration::STATUSES) }
    it { is_expected.to validate_inclusion_of(:base).in_array(ReportExoneration::BASES) }
    it { is_expected.to validate_inclusion_of(:code_collectivite).in_array(ReportExoneration::CODES_COLLECTIVITE) }
  end
end
