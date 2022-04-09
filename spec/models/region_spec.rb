# frozen_string_literal: true

require "rails_helper"

RSpec.describe Region, type: :model do
  # Associations
  # ----------------------------------------------------------------------------
  it { is_expected.to have_many(:departements) }

  it { is_expected.to have_many(:communes) }
  it { is_expected.to have_many(:epcis) }
  it { is_expected.to have_many(:ddfips) }
  it { is_expected.to have_many(:collectivities) }

  # Validations
  # ----------------------------------------------------------------------------
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:code_region) }

  it { is_expected.to     allow_value("12")  .for(:code_region) }
  it { is_expected.not_to allow_value("12AB").for(:code_region) }

  context "with an existing region" do
    before { create(:region) }

    it { is_expected.to validate_uniqueness_of(:code_region).case_insensitive }
  end

  # Search
  # ----------------------------------------------------------------------------
  describe ".search" do
    it do
      expect{
        described_class.search(name: "Hello").load
      }.to perform_sql_query(<<~SQL.squish)
        SELECT "regions".*
        FROM   "regions"
        WHERE  (LOWER(UNACCENT("regions"."name")) LIKE LOWER(UNACCENT('%Hello%')))
      SQL
    end

    it do
      expect{
        described_class.search("Hello").load
      }.to perform_sql_query(<<~SQL.squish)
        SELECT "regions".*
        FROM   "regions"
        WHERE (LOWER(UNACCENT("regions"."name")) LIKE LOWER(UNACCENT('%Hello%'))
          OR "regions"."code_region" = 'Hello')
      SQL
    end
  end
end
