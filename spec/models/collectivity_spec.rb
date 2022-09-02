# frozen_string_literal: true

require "rails_helper"

RSpec.describe Collectivity, type: :model do
  # Associations
  # ----------------------------------------------------------------------------
  it { is_expected.to belong_to(:territory).required }
  it { is_expected.to belong_to(:publisher).optional }
  it { is_expected.to have_many(:users) }

  # Validations
  # ----------------------------------------------------------------------------
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:siren) }

  it { is_expected.to     allow_value("801453893") .for(:siren) }
  it { is_expected.not_to allow_value("1234567AB") .for(:siren) }
  it { is_expected.not_to allow_value("1234567891").for(:siren) }

  it { is_expected.to     allow_value("foo@bar.com")        .for(:contact_email) }
  it { is_expected.to     allow_value("foo@bar")            .for(:contact_email) }
  it { is_expected.to     allow_value("foo@bar-bar.bar.com").for(:contact_email) }
  it { is_expected.not_to allow_value("foo.bar.com")        .for(:contact_email) }

  it { is_expected.to     allow_value("0123456789")        .for(:contact_phone) }
  it { is_expected.to     allow_value("123456789")         .for(:contact_phone) }
  it { is_expected.to     allow_value("01 23 45 67 89")    .for(:contact_phone) }
  it { is_expected.to     allow_value("+33 1 23 45 67 89") .for(:contact_phone) }
  it { is_expected.to     allow_value("+590 1 23 45 67 89").for(:contact_phone) }
  it { is_expected.not_to allow_value("01234567")          .for(:contact_phone) }
  it { is_expected.not_to allow_value("+44 1 23 45 67 89") .for(:contact_phone) }

  it { is_expected.to     allow_value("Commune")    .for(:territory_type) }
  it { is_expected.to     allow_value("EPCI")       .for(:territory_type) }
  it { is_expected.to     allow_value("Departement").for(:territory_type) }
  it { is_expected.not_to allow_value("DDFIP")      .for(:territory_type) }

  context "with an existing collectivity" do
    # FYI: If you're experimenting errors due to accents,
    # you should read ./docs/uniqueness_validations_and_accents.md
    before { create(:collectivity) }

    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
    it { is_expected.to validate_uniqueness_of(:siren).case_insensitive }
  end

  context "when existing collectivity is discarded" do
    before { create(:collectivity, :discarded) }

    it { is_expected.not_to validate_uniqueness_of(:name).case_insensitive }
    it { is_expected.not_to validate_uniqueness_of(:siren).case_insensitive }
  end

  # Formatting before save
  # ----------------------------------------------------------------------------
  it { expect(create(:collectivity, contact_phone: "0123456789")).to        have_attributes(contact_phone: "0123456789") }
  it { expect(create(:collectivity, contact_phone: "01 23 45 67 89")).to    have_attributes(contact_phone: "0123456789") }
  it { expect(create(:collectivity, contact_phone: "+33 1 23 45 67 89")).to have_attributes(contact_phone: "+33123456789") }
  it { expect(create(:collectivity, contact_phone: "")).to                  have_attributes(contact_phone: "") }
  it { expect(create(:collectivity, contact_phone: nil)).to                 have_attributes(contact_phone: nil) }

  # Search
  # ----------------------------------------------------------------------------
  describe ".search" do
    it do
      expect {
        described_class.search("Hello").load
      }.to perform_sql_query(<<~SQL.squish)
        SELECT "collectivities".*
        FROM   "collectivities"
        LEFT OUTER JOIN "publishers" ON "publishers"."id" = "collectivities"."publisher_id"
        WHERE (LOWER(UNACCENT("collectivities"."name")) LIKE LOWER(UNACCENT('%Hello%'))
          OR "collectivities"."siren" = 'Hello'
          OR "publishers"."name" = 'Hello')
      SQL
    end
  end

  # Counter caches
  # ----------------------------------------------------------------------------
  describe "counter caches" do
    let!(:collectivity1) { create(:collectivity) }
    let!(:collectivity2) { create(:collectivity) }

    describe "#users_count" do
      let(:user) { create(:user, organization: collectivity1) }

      it "changes on creation" do
        expect { user }
          .to      change { collectivity1.reload.users_count }.from(0).to(1)
          .and not_change { collectivity2.reload.users_count }.from(0)
      end

      it "changes on deletion" do
        user
        expect { user.destroy }
          .to      change { collectivity1.reload.users_count }.from(1).to(0)
          .and not_change { collectivity2.reload.users_count }.from(0)
      end

      it "changes on updating" do
        user
        expect { user.update(organization: collectivity2) }
          .to  change { collectivity1.reload.users_count }.from(1).to(0)
          .and change { collectivity2.reload.users_count }.from(0).to(1)
      end
    end
  end

  # Reset counters
  # ----------------------------------------------------------------------------
  describe ".reset_all_counters" do
    subject { described_class.reset_all_counters }

    let!(:collectivity1) { create(:collectivity) }
    let!(:collectivity2) { create(:collectivity) }

    its_block { is_expected.to ret(2) }
    its_block { is_expected.to perform_sql_query("SELECT reset_all_collectivities_counters()") }

    before do
      create_list(:user, 4, organization: collectivity1)
      create_list(:user, 2, organization: collectivity2)
      create_list(:user, 1, :publisher)
      create_list(:user, 1, :ddfip)

      Collectivity.update_all(users_count: 0)
    end

    its_block { is_expected.to change { collectivity1.reload.users_count }.from(0).to(4) }
    its_block { is_expected.to change { collectivity2.reload.users_count }.from(0).to(2) }
  end
end
