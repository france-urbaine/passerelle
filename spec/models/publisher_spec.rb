# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publisher, type: :model do
  # Associations
  # ----------------------------------------------------------------------------
  it { is_expected.to have_many(:collectivities) }
  it { is_expected.to have_many(:users) }

  # Validations
  # ----------------------------------------------------------------------------
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:siren) }

  it { is_expected.to     allow_value("801453893").for(:siren) }
  it { is_expected.not_to allow_value("1234567AB").for(:siren) }
  it { is_expected.not_to allow_value("1234567891").for(:siren) }

  it { is_expected.to     allow_value("foo@bar.com")        .for(:email) }
  it { is_expected.to     allow_value("foo@bar")            .for(:email) }
  it { is_expected.to     allow_value("foo@bar-bar.bar.com").for(:email) }
  it { is_expected.not_to allow_value("foo.bar.com")        .for(:email) }

  context "with an existing publisher" do
    before { create(:publisher) }

    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
    it { is_expected.to validate_uniqueness_of(:siren).case_insensitive }
  end

  # Search
  # ----------------------------------------------------------------------------
  describe ".search" do
    it do
      expect{
        described_class.search("Hello").load
      }.to perform_sql_query(<<~SQL.squish)
        SELECT "publishers".*
        FROM   "publishers"
        WHERE (LOWER(UNACCENT("publishers"."name")) LIKE LOWER(UNACCENT('%Hello%'))
          OR "publishers"."siren" = 'Hello')
      SQL
    end
  end
end
