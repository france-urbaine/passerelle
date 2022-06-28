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
    # FYI: About uniqueness validations, case insensitivity and accents:
    # You should read ./docs/uniqueness_validations_and_accents.md
    before { create(:publisher) }

    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
    it { is_expected.to validate_uniqueness_of(:siren).case_insensitive }
  end

  context "when existing publisher is discarded" do
    before { create(:publisher, :discarded) }

    it { is_expected.not_to validate_uniqueness_of(:name).case_insensitive }
    it { is_expected.not_to validate_uniqueness_of(:siren).case_insensitive }
  end

  # Search
  # ----------------------------------------------------------------------------
  describe ".search" do
    it do
      expect {
        described_class.search("Hello").load
      }.to perform_sql_query(<<~SQL.squish)
        SELECT "publishers".*
        FROM   "publishers"
        WHERE (LOWER(UNACCENT("publishers"."name")) LIKE LOWER(UNACCENT('%Hello%'))
          OR "publishers"."siren" = 'Hello')
      SQL
    end
  end

  # Order scope
  # ----------------------------------------------------------------------------
  describe ".order_by_param" do
    it do
      expect {
        described_class.order_by_param("name").load
      }.to perform_sql_query(<<~SQL)
        SELECT "publishers".*
        FROM   "publishers"
        ORDER BY UNACCENT("publishers"."name") ASC, "publishers"."created_at" ASC
      SQL
    end

    it do
      expect {
        described_class.order_by_param("-name").load
      }.to perform_sql_query(<<~SQL)
        SELECT "publishers".*
        FROM   "publishers"
        ORDER BY UNACCENT("publishers"."name") DESC, "publishers"."created_at" DESC
      SQL
    end
  end

  describe ".order_by_score" do
    it do
      expect {
        described_class.order_by_score("Hello").load
      }.to perform_sql_query(<<~SQL)
        SELECT "publishers".*
        FROM   "publishers"
        ORDER BY ts_rank_cd(to_tsvector('french', "publishers"."name"), to_tsquery('french', 'Hello')) DESC,
                 "publishers"."created_at" ASC
      SQL
    end
  end

  # Reset counters
  # ----------------------------------------------------------------------------
  describe ".reset_all_counters" do
    subject { described_class.reset_all_counters }

    let!(:publisher1) { create(:publisher) }
    let!(:publisher2) { create(:publisher) }

    describe "on users_count" do
      before do
        create_list(:user, 4, organization: publisher1)
        create_list(:user, 2, organization: publisher2)
        create_list(:user, 1, :publisher)
        create_list(:user, 1, :collectivity)

        Publisher.update_all(users_count: 0)
      end

      its_block { is_expected.to change { publisher1.reload.users_count }.from(0).to(4) }
      its_block { is_expected.to change { publisher2.reload.users_count }.from(0).to(2) }
    end

    describe "on collectivities_count" do
      before do
        create_list(:collectivity, 3, publisher: publisher1)
        create_list(:collectivity, 2, publisher: publisher2)
        create_list(:collectivity, 2, :discarded, publisher: publisher2)
        create_list(:collectivity, 1)

        Publisher.update_all(collectivities_count: 0)
      end

      it        { is_expected.to eq(2) }
      its_block { is_expected.to change { publisher1.reload.collectivities_count }.from(0).to(3) }
      its_block { is_expected.to change { publisher2.reload.collectivities_count }.from(0).to(2) }
    end
  end
end
