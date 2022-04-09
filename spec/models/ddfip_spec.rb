# frozen_string_literal: true

require "rails_helper"

RSpec.describe DDFIP, type: :model do
  # Associations
  # ----------------------------------------------------------------------------
  it { is_expected.to belong_to(:departement).required }
  it { is_expected.to have_many(:users) }
  it { is_expected.to have_one(:region) }

  # Validations
  # ----------------------------------------------------------------------------
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:code_departement) }

  it { is_expected.to     allow_value("01").for(:code_departement) }
  it { is_expected.to     allow_value("2A").for(:code_departement) }
  it { is_expected.to     allow_value("987").for(:code_departement) }
  it { is_expected.not_to allow_value("1").for(:code_departement) }
  it { is_expected.not_to allow_value("123").for(:code_departement) }
  it { is_expected.not_to allow_value("3C").for(:code_departement) }

  context "with an existing DDFIP" do
    # FYI: About uniqueness validations, case insensitivity and accents:
    # You should read ./docs/uniqueness_validations_and_accents.md
    before { create(:ddfip, name: "Vendee") }

    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  end

  # Search
  # ----------------------------------------------------------------------------
  describe ".search" do
    it do
      expect{
        described_class.search("Hello").load
      }.to perform_sql_query(<<~SQL.squish)
        SELECT "ddfips".*
        FROM   "ddfips"
        WHERE (LOWER(UNACCENT("ddfips"."name")) LIKE LOWER(UNACCENT('%Hello%'))
          OR "ddfips"."code_departement" = 'Hello')
      SQL
    end
  end
end
