# frozen_string_literal: true

require "rails_helper"

RSpec.describe DGFIP do
  # Associations
  # ----------------------------------------------------------------------------
  describe "associations" do
    it { is_expected.to have_many(:users) }
  end

  # Validations
  # ----------------------------------------------------------------------------
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }

    it "validates uniqueness of :name" do
      create(:dgfip)
      is_expected.to validate_uniqueness_of(:name).ignoring_case_sensitivity
    end

    it "ignores discarded records when validating uniqueness of :name" do
      create(:dgfip, :discarded)
      is_expected.not_to validate_uniqueness_of(:name).ignoring_case_sensitivity
    end

    it "validates only one dgfip on creation" do
      create(:dgfip)
      expect { create(:dgfip) }.to raise_error(ActiveRecord::RecordInvalid).with_message("La validation a échoué : Une seule DGFIP est possible")
    end

    it "validates only one dgfip on undiscard" do
      create(:dgfip)
      discarded_dgfip = create(:dgfip, :discarded)
      expect { discarded_dgfip.undiscard }.to raise_error(ActiveRecord::RecordInvalid).with_message("La validation a échoué : Une seule DGFIP est possible")
    end

    it "allows to undiscard dgfip if others are discarded" do
      create(:dgfip, :discarded)
      discarded_dgfip = create(:dgfip, :discarded)
      expect { discarded_dgfip.undiscard }.to not_raise_error
    end
  end

  # Scopes
  # ----------------------------------------------------------------------------
  describe "scopes" do
    describe ".search" do
      it "searches for DGFIPs with all criteria" do
        expect {
          described_class.search("Hello").load
        }.to perform_sql_query(<<~SQL.squish)
          SELECT "dgfips".*
          FROM   "dgfips"
          WHERE  (LOWER(UNACCENT("dgfips"."name")) LIKE LOWER(UNACCENT('%Hello%')))
        SQL
      end

      it "searches for DDFIPs by matching name" do
        expect {
          described_class.search(name: "Hello").load
        }.to perform_sql_query(<<~SQL.squish)
          SELECT "dgfips".*
          FROM   "dgfips"
          WHERE  (LOWER(UNACCENT("dgfips"."name")) LIKE LOWER(UNACCENT('%Hello%')))
        SQL
      end
    end

    describe ".autocomplete" do
      it "searches for DGFIPs with text matching the name" do
        expect {
          described_class.autocomplete("Hello").load
        }.to perform_sql_query(<<~SQL)
          SELECT "dgfips".*
          FROM   "dgfips"
          WHERE  (LOWER(UNACCENT("dgfips"."name")) LIKE LOWER(UNACCENT('%Hello%')))
        SQL
      end
    end
  end

  # Updates methods
  # ----------------------------------------------------------------------------
  describe "update methods" do
    describe ".reset_all_counters" do
      subject(:reset_all_counters) { described_class.reset_all_counters }

      let!(:dgfips) { create_list(:dgfip, 1) }

      it { expect { reset_all_counters }.to perform_sql_query("SELECT reset_all_dgfips_counters()") }

      it "returns the count of DGFIPs" do
        expect(reset_all_counters).to eq(1)
      end

      describe "on users_count" do
        before do
          create_list(:user, 4, organization: dgfips[0])
          create_list(:user, 1, :publisher)
          create_list(:user, 1, :collectivity)

          DGFIP.update_all(users_count: 0)
        end

        it "resets counters" do
          expect { reset_all_counters }
            .to  change { dgfips[0].reload.users_count }.from(0).to(4)
        end
      end
    end

    # Database constraints and triggers
    # ----------------------------------------------------------------------------
    describe "database constraints" do
      it "asserts the uniqueness of name" do
        existing_dgfip = create(:dgfip)
        another_dgfip  = build(:dgfip, name: existing_dgfip.name)

        expect { another_dgfip.save(validate: false) }
          .to raise_error(ActiveRecord::RecordNotUnique).with_message(/PG::UniqueViolation/)
      end

      it "ignores discarded records when asserting the uniqueness of name" do
        existing_dgfip = create(:dgfip, :discarded)
        another_dgfip  = build(:dgfip, name: existing_dgfip.name)

        expect { another_dgfip.save(validate: false) }
          .not_to raise_error
      end
    end

    describe "database triggers" do
      let!(:dgfips) { create_list(:dgfip, 2, :discarded) }

      describe "about organization counter caches" do
        describe "#users_count" do
          let(:user) { create(:user, organization: dgfips[0]) }

          it "changes on creation" do
            expect { user }
              .to change { dgfips[0].reload.users_count }.from(0).to(1)
              .and not_change { dgfips[1].reload.users_count }.from(0)
          end

          it "changes on deletion" do
            user
            expect { user.destroy }
              .to change { dgfips[0].reload.users_count }.from(1).to(0)
              .and not_change { dgfips[1].reload.users_count }.from(0)
          end

          it "changes when discarding" do
            user
            expect { user.discard }
              .to change { dgfips[0].reload.users_count }.from(1).to(0)
              .and not_change { dgfips[1].reload.users_count }.from(0)
          end

          it "changes when undiscarding" do
            user.discard
            expect { user.undiscard }
              .to change { dgfips[0].reload.users_count }.from(0).to(1)
              .and not_change { dgfips[1].reload.users_count }.from(0)
          end

          it "changes when updating organization" do
            user
            expect { user.update(organization: dgfips[1]) }
              .to  change { dgfips[0].reload.users_count }.from(1).to(0)
              .and change { dgfips[1].reload.users_count }.from(0).to(1)
          end
        end
      end
    end
  end
end
