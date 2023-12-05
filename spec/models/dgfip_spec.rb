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
      let_it_be(:dgfip) { create(:dgfip) }

      it "performs a single SQL function" do
        expect { described_class.reset_all_counters }
          .to perform_sql_query("SELECT reset_all_dgfips_counters()")
      end

      it "returns the number of concerned collectivities" do
        expect(described_class.reset_all_counters).to eq(1)
      end

      describe "users counts" do
        before_all do
          create_list(:user, 2)
          create_list(:user, 4, organization: dgfip)
          create(:user, :discarded, organization: dgfip)

          DGFIP.update_all(users_count: 99)
        end

        it "updates #users_count" do
          expect {
            described_class.reset_all_counters
          }.to change { dgfip.reload.users_count }.to(4)
        end
      end

      describe "reports & packages counts" do
        before_all do
          create(:publisher, :with_users, users_size: 1).tap do |publisher|
            create(:collectivity, :with_users, publisher:, users_size: 1).tap do |collectivity|
              create(:report, collectivity:)
              create(:report, :sandbox, collectivity:)
              create(:report, :denied, collectivity:)
              create_list(:report, 2, :approved, collectivity:)
              create_list(:report, 3, :rejected, collectivity:)
            end
          end

          DGFIP.update_all(
            reports_transmitted_count: 99,
            reports_denied_count:      99,
            reports_processing_count:  99,
            reports_approved_count:    99,
            reports_rejected_count:    99
          )
        end

        it "updates #reports_transmitted_count" do
          expect {
            described_class.reset_all_counters
          }.to change { dgfip.reload.reports_transmitted_count }.to(6)
        end

        it "updates #reports_denied_count" do
          expect {
            described_class.reset_all_counters
          }.to change { dgfip.reload.reports_denied_count }.to(1)
        end

        it "updates #reports_processing_count" do
          expect {
            described_class.reset_all_counters
          }.to change { dgfip.reload.reports_processing_count }.to(0)
        end

        it "updates #reports_approved_count" do
          expect {
            described_class.reset_all_counters
          }.to change { dgfip.reload.reports_approved_count }.to(2)
        end

        it "updates #reports_rejected_count" do
          expect {
            described_class.reset_all_counters
          }.to change { dgfip.reload.reports_rejected_count }.to(3)
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

      it "changes when user is discarded" do
        user

        expect { user.discard }
          .to change { dgfip.reload.users_count }.from(1).to(0)
      end

      it "changes when user is undiscarded" do
        user.discard

        expect { user.undiscard }
          .to change { dgfip.reload.users_count }.from(0).to(1)
      end

      it "changes when user switches to another organization" do
        user
        ddfip = create(:ddfip)

        expect { user.update(organization: ddfip) }
          .to change { dgfip.reload.users_count }.from(1).to(0)
      end
    end

    describe "#reports_transmitted_count" do
      let(:collectivity) { create(:collectivity) }
      let(:report)       { create(:report, collectivity:) }

      it "doesn't change when report is created" do
        expect { report }
          .not_to change { dgfip.reload.reports_transmitted_count }.from(0)
      end

      it "changes when report is transmitted" do
        report

        expect { report.transmit! }
          .to change { dgfip.reload.reports_transmitted_count }.from(0).to(1)
      end

      it "doesn't change when report is transmitted to a sandbox" do
        report.update(sandbox: true)

        expect { report.transmit! }
          .not_to change { dgfip.reload.reports_transmitted_count }.from(0)
      end

      it "changes when transmitted report is discarded" do
        report.transmit!

        expect { report.discard }
          .to change { dgfip.reload.reports_transmitted_count }.from(1).to(0)
      end

      it "changes when transmitted report is undiscarded" do
        report.transmit!
        report.discard

        expect { report.undiscard }
          .to change { dgfip.reload.reports_transmitted_count }.from(0).to(1)
      end

      it "changes when transmitted report is deleted" do
        report.transmit!

        expect { report.destroy }
          .to change { dgfip.reload.reports_transmitted_count }.from(1).to(0)
      end
    end

    describe "#reports_denied_count" do
      let(:collectivity) { create(:collectivity) }
      let(:report)       { create(:report, :transmitted, collectivity:) }

      it "doesn't change when report are transmitted" do
        expect { report }
          .not_to change { dgfip.reload.reports_denied_count }.from(0)
      end

      it "changes when report is denied" do
        report

        expect { report.deny! }
          .to change { dgfip.reload.reports_denied_count }.from(0).to(1)
      end

      it "doesn't change when report is assigned" do
        report

        expect { report.assign! }
          .not_to change { dgfip.reload.reports_denied_count }.from(0)
      end

      it "changes when denied report is then assigned" do
        report.deny!

        expect { report.assign! }
          .to change { dgfip.reload.reports_denied_count }.from(1).to(0)
      end

      it "changes when denied report is discarded" do
        report.deny!

        expect { report.discard }
          .to change { dgfip.reload.reports_denied_count }.from(1).to(0)
      end

      it "changes when denied report is undiscarded" do
        report.deny!
        report.discard

        expect { report.undiscard }
          .to change { dgfip.reload.reports_denied_count }.from(0).to(1)
      end

      it "changes when denied report is deleted" do
        report.deny!

        expect { report.delete }
          .to change { dgfip.reload.reports_denied_count }.from(1).to(0)
      end

      it "change when denied report is sandboxed" do
        report.deny!

        expect { report.update(sandbox: true) }
          .to change { dgfip.reload.reports_denied_count }.from(1).to(0)
      end
    end

    describe "#reports_processing_count" do
      let(:collectivity) { create(:collectivity) }
      let(:report)       { create(:report, collectivity:) }

      it "doesn't change when report is transmitted" do
        expect { report }
          .not_to change { dgfip.reload.reports_processing_count }.from(0)
      end

      it "changes when report is assigned" do
        report

        expect { report.assign! }
          .to change { dgfip.reload.reports_processing_count }.from(0).to(1)
      end

      it "doesn't change when report is denied" do
        report

        expect { report.deny! }
          .not_to change { dgfip.reload.reports_processing_count }.from(0)
      end

      it "changes when assigned report is then denied" do
        report.assign!

        expect { report.deny! }
          .to change { dgfip.reload.reports_processing_count }.from(1).to(0)
      end

      it "changes when report is approved" do
        report.assign!

        expect { report.approve! }
          .to change { dgfip.reload.reports_processing_count }.from(1).to(0)
      end

      it "changes when report is rejected" do
        report.assign!

        expect { report.reject! }
          .to change { dgfip.reload.reports_processing_count }.from(1).to(0)
      end

      it "changes when assigned report is then discarded" do
        report.assign!

        expect { report.discard }
          .to change { dgfip.reload.reports_processing_count }.from(1).to(0)
      end

      it "changes when assigned report is undiscarded" do
        report.assign!
        report.discard

        expect { report.undiscard }
          .to change { dgfip.reload.reports_processing_count }.from(0).to(1)
      end

      it "changes when assigned report is sandboxed" do
        report.assign!

        expect { report.update(sandbox: true) }
          .to change { dgfip.reload.reports_processing_count }.from(1).to(0)
      end
    end

    describe "#reports_approved_count" do
      let(:collectivity) { create(:collectivity) }
      let(:report)       { create(:report, :assigned, collectivity:) }

      it "doesn't change when report is assigned" do
        expect { report }
          .not_to change { dgfip.reload.reports_approved_count }.from(0)
      end

      it "doesn't changes when report is rejected" do
        report

        expect { report.reject! }
          .not_to change { dgfip.reload.reports_approved_count }.from(0)
      end

      it "changes when report is approved" do
        report

        expect { report.approve! }
          .to change { dgfip.reload.reports_approved_count }.from(0).to(1)
      end

      it "changes when approved report is reseted" do
        report.approve!

        expect { report.update(approved_at: nil, state: "processing") }
          .to change { dgfip.reload.reports_approved_count }.from(1).to(0)
      end

      it "changes when approved report is rejected" do
        report.approve!

        expect { report.reject! }
          .to change { dgfip.reload.reports_approved_count }.from(1).to(0)
      end

      it "changes when approved report is then discarded" do
        report.approve!

        expect { report.discard }
          .to change { dgfip.reload.reports_approved_count }.from(1).to(0)
      end

      it "changes when approved report is undiscarded" do
        report.approve!
        report.discard

        expect { report.undiscard }
          .to change { dgfip.reload.reports_approved_count }.from(0).to(1)
      end

      it "changes when approved report is sandboxed" do
        report.approve!

        expect { report.update(sandbox: true) }
          .to change { dgfip.reload.reports_approved_count }.from(1).to(0)
      end
    end

    describe "#reports_rejected_count" do
      let(:collectivity) { create(:collectivity) }
      let(:report)       { create(:report, :assigned, collectivity:) }

      it "doesn't change when report is assigned" do
        expect { report }
          .not_to change { dgfip.reload.reports_rejected_count }.from(0)
      end

      it "doesn't changes when report is approved" do
        report

        expect { report.approve! }
          .not_to change { dgfip.reload.reports_rejected_count }.from(0)
      end

      it "changes when report is rejected" do
        report

        expect { report.reject! }
          .to change { dgfip.reload.reports_rejected_count }.from(0).to(1)
      end

      it "changes when rejected report is reseted" do
        report.reject!

        expect { report.update(rejected_at: nil, state: "processing") }
          .to change { dgfip.reload.reports_rejected_count }.from(1).to(0)
      end

      it "changes when rejected report is approved" do
        report.reject!

        expect { report.approve! }
          .to change { dgfip.reload.reports_rejected_count }.from(1).to(0)
      end

      it "changes when rejected report is then discarded" do
        report.reject!

        expect { report.discard }
          .to change { dgfip.reload.reports_rejected_count }.from(1).to(0)
      end

      it "changes when rejected report is undiscarded" do
        report.reject!
        report.discard

        expect { report.undiscard }
          .to change { dgfip.reload.reports_rejected_count }.from(0).to(1)
      end

      it "changes when rejected report is sandboxed" do
        report.reject!

        expect { report.update(sandbox: true) }
          .to change { dgfip.reload.reports_rejected_count }.from(1).to(0)
      end
    end
  end
end
