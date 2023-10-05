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

    it "validates that no other one DGFIP exist on creation" do
      create(:dgfip)

      expect {
        create(:dgfip)
      }.to raise_error(ActiveRecord::RecordInvalid).with_message(/Une instance .+ a déjà été crée/)
    end

    it "cannot create a new DGFIP when another one is discarded" do
      create(:dgfip, :discarded)

      expect {
        create(:dgfip)
      }.to raise_error(ActiveRecord::RecordInvalid).with_message(/Une instance .+ a déjà été crée/)
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
  end

  # Singleton record
  # ----------------------------------------------------------------------------
  describe ".find_or_create_singleton_record" do
    it "creates a new record when no other one exists" do
      expect {
        DGFIP.find_or_create_singleton_record
      }.to change(DGFIP, :count).by(1)
    end

    it "assigns default values to new record" do
      dgfip = DGFIP.find_or_create_singleton_record

      expect(dgfip).to have_attributes(name: "Direction générale des Finances publiques")
    end

    it "returns existing record" do
      dgfip = create(:dgfip)

      expect(DGFIP.find_or_create_singleton_record).to eq(dgfip)
    end

    it "undiscard existing but discarded record" do
      dgfip = create(:dgfip, :discarded)

      expect(DGFIP.find_or_create_singleton_record)
        .to eq(dgfip)
        .and be_undiscarded
    end
  end

  # Database constraints and triggers
  # ----------------------------------------------------------------------------
  describe "database constraints" do
    it "asserts the uniqueness of a single record" do
      create(:dgfip)

      expect {
        build(:dgfip).save(validate: false)
      }.to raise_error(ActiveRecord::RecordNotUnique).with_message(/PG::UniqueViolation/)
    end

    it "doesn't ignore discarded records when asserting the uniqueness of a single record" do
      create(:dgfip, :discarded)

      expect {
        build(:dgfip).save(validate: false)
      }.to raise_error(ActiveRecord::RecordNotUnique).with_message(/PG::UniqueViolation/)
    end
  end

  describe "database triggers" do
    let!(:dgfip) { create(:dgfip) }

    describe "about organization counter caches" do
      describe "#users_count" do
        let(:user) { create(:user, organization: dgfip) }

        it "changes on creation" do
          expect { user }
            .to change { dgfip.reload.users_count }.from(0).to(1)
        end

        it "changes on deletion" do
          user

          expect { user.destroy }
            .to change { dgfip.reload.users_count }.from(1).to(0)
        end

        it "changes when discarding" do
          user

          expect { user.discard }
            .to change { dgfip.reload.users_count }.from(1).to(0)
        end

        it "changes when undiscarding" do
          user.discard

          expect { user.undiscard }
            .to change { dgfip.reload.users_count }.from(0).to(1)
        end

        it "changes when updating organization" do
          ddfip = create(:ddfip)
          user

          expect { user.update(organization: ddfip) }
            .to  change { dgfip.reload.users_count }.from(1).to(0)
        end
      end

      describe "#reports_delivered_count" do
        let(:package) { create(:package) }
        let(:report) { create(:report, package: package) }

        it "changes on report creation" do
          expect { report }
            .to change { dgfip.reload.reports_delivered_count }.from(0).to(1)
        end

        it "changes on report deletion" do
          report

          expect { report.destroy }
            .to change { dgfip.reload.reports_delivered_count }.from(1).to(0)
        end

        it "changes on package deletion" do
          report

          expect { report.package.destroy }
            .to change { dgfip.reload.reports_delivered_count }.from(1).to(0)
        end

        it "changes when discarding report" do
          report

          expect { report.discard }
            .to change { dgfip.reload.reports_delivered_count }.from(1).to(0)
        end

        it "changes when discarding package" do
          report

          expect { report.package.discard }
            .to change { dgfip.reload.reports_delivered_count }.from(1).to(0)
        end

        it "changes when undiscarding report" do
          report.discard

          expect { report.undiscard }
            .to change { dgfip.reload.reports_delivered_count }.from(0).to(1)
        end

        it "changes when undiscarding package" do
          report.package.discard

          expect { report.package.undiscard }
            .to change { dgfip.reload.reports_delivered_count }.from(0).to(1)
        end

        it "changes when package is set to sandbox" do
          report

          expect { report.package.update(sandbox: true) }
            .to  change { dgfip.reload.reports_delivered_count }.from(1).to(0)
        end
      end

      describe "#reports_approved_count" do
        let(:report) { create(:report, :approved) }

        it "changes on report creation" do
          expect { report }
            .to change { dgfip.reload.reports_approved_count }.from(0).to(1)
        end

        it "changes on report deletion" do
          report

          expect { report.destroy }
            .to change { dgfip.reload.reports_approved_count }.from(1).to(0)
        end

        it "changes on package deletion" do
          report

          expect { report.package.destroy }
            .to change { dgfip.reload.reports_approved_count }.from(1).to(0)
        end

        it "changes when discarding report" do
          report

          expect { report.discard }
            .to change { dgfip.reload.reports_approved_count }.from(1).to(0)
        end

        it "changes when discarding package" do
          report

          expect { report.package.discard }
            .to change { dgfip.reload.reports_approved_count }.from(1).to(0)
        end

        it "changes when undiscarding report" do
          report.discard

          expect { report.undiscard }
            .to change { dgfip.reload.reports_approved_count }.from(0).to(1)
        end

        it "changes when undiscarding package" do
          report.package.discard

          expect { report.package.undiscard }
            .to change { dgfip.reload.reports_approved_count }.from(0).to(1)
        end

        it "changes when package is set to sandbox" do
          report

          expect { report.package.update(sandbox: true) }
            .to  change { dgfip.reload.reports_approved_count }.from(1).to(0)
        end
      end

      describe "#reports_rejected_count" do
        let(:report) { create(:report, :rejected) }

        it "changes on report creation" do
          expect { report }
            .to change { dgfip.reload.reports_rejected_count }.from(0).to(1)
        end

        it "changes on report deletion" do
          report

          expect { report.destroy }
            .to change { dgfip.reload.reports_rejected_count }.from(1).to(0)
        end

        it "changes on package deletion" do
          report

          expect { report.package.destroy }
            .to change { dgfip.reload.reports_rejected_count }.from(1).to(0)
        end

        it "changes when discarding report" do
          report

          expect { report.discard }
            .to change { dgfip.reload.reports_rejected_count }.from(1).to(0)
        end

        it "changes when discarding package" do
          report

          expect { report.package.discard }
            .to change { dgfip.reload.reports_rejected_count }.from(1).to(0)
        end

        it "changes when undiscarding report" do
          report.discard

          expect { report.undiscard }
            .to change { dgfip.reload.reports_rejected_count }.from(0).to(1)
        end

        it "changes when undiscarding package" do
          report.package.discard

          expect { report.package.undiscard }
            .to change { dgfip.reload.reports_rejected_count }.from(0).to(1)
        end

        it "changes when package is set to sandbox" do
          report

          expect { report.package.update(sandbox: true) }
            .to  change { dgfip.reload.reports_rejected_count }.from(1).to(0)
        end
      end
    end
  end
end
