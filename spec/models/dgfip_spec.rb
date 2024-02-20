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

  # Scopes: searches
  # ----------------------------------------------------------------------------
  describe "search scopes" do
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

      describe "reports counts" do
        before_all do
          create(:publisher, :with_users, users_size: 1).tap do |publisher|
            create(:collectivity, :with_users, publisher:, users_size: 1).tap do |collectivity|
              create(:report, collectivity:)
              create(:report, :ready, collectivity:)
              create(:report, :transmitted_to_sandbox, collectivity:)
              create(:report, :transmitted, collectivity:)
              create(:report, :assigned, collectivity:)
              create(:report, :assigned, :applicable, collectivity:)
              create(:report, :approved, collectivity:)
              create(:report, :canceled, collectivity:)
              create(:report, :rejected, collectivity:)
            end
          end

          DGFIP.update_all(
            reports_transmitted_count: 99,
            reports_accepted_count:    99,
            reports_rejected_count:    99,
            reports_approved_count:    99,
            reports_canceled_count:    99
          )
        end

        it "updates #reports_transmitted_count" do
          expect {
            described_class.reset_all_counters
          }.to change { dgfip.reload.reports_transmitted_count }.to(6)
        end

        it "updates #reports_accepted_count" do
          expect {
            described_class.reset_all_counters
          }.to change { dgfip.reload.reports_accepted_count }.to(4)
        end

        it "updates #reports_rejected_count" do
          expect {
            described_class.reset_all_counters
          }.to change { dgfip.reload.reports_rejected_count }.to(1)
        end

        it "updates #reports_approved_count" do
          expect {
            described_class.reset_all_counters
          }.to change { dgfip.reload.reports_approved_count }.to(1)
        end

        it "updates #reports_canceled_count" do
          expect {
            described_class.reset_all_counters
          }.to change { dgfip.reload.reports_canceled_count }.to(1)
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

    def create_user(*traits, **attributes)
      create(:user, *traits, organization: dgfip, **attributes)
    end

    def create_report(*traits, **attributes)
      create(:report, *traits, **attributes)
    end

    describe "#users_count" do
      it "changes on creation" do
        expect { create_user }
          .to change { dgfip.reload.users_count }.from(0).to(1)
      end

      it "changes on deletion" do
        user = create_user

        expect { user.delete }
          .to change { dgfip.reload.users_count }.from(1).to(0)
      end

      it "changes when user is discarded" do
        user = create_user

        expect { user.update_columns(discarded_at: Time.current) }
          .to change { dgfip.reload.users_count }.from(1).to(0)
      end

      it "changes when user is undiscarded" do
        user = create_user(:discarded)

        expect { user.update_columns(discarded_at: nil) }
          .to change { dgfip.reload.users_count }.from(0).to(1)
      end

      it "changes when user switches to another organization" do
        user = create_user
        ddfip = create(:ddfip)

        expect { user.update_columns(organization_id: ddfip.id) }
          .to change { dgfip.reload.users_count }.from(1).to(0)
      end
    end

    describe "#reports_transmitted_count" do
      it "doesn't change when report is created" do
        expect { create_report }
          .not_to change { dgfip.reload.reports_transmitted_count }.from(0)
      end

      it "changes when report is transmitted" do
        report = create_report

        expect { report.update_columns(state: "transmitted") }
          .to change { dgfip.reload.reports_transmitted_count }.from(0).to(1)
      end

      it "doesn't change when report is transmitted to a sandbox" do
        report = create_report

        expect { report.update_columns(state: "transmitted", sandbox: true) }
          .not_to change { dgfip.reload.reports_transmitted_count }.from(0)
      end

      it "doesn't change when transmitted report is assigned" do
        report = create_report(:transmitted)

        expect { report.update_columns(state: "assigned") }
          .not_to change { dgfip.reload.reports_transmitted_count }.from(1)
      end

      it "changes when transmitted report is discarded" do
        report = create_report(:transmitted)

        expect { report.update_columns(discarded_at: Time.current) }
          .to change { dgfip.reload.reports_transmitted_count }.from(1).to(0)
      end

      it "changes when transmitted report is undiscarded" do
        report = create_report(:transmitted, :discarded)

        expect { report.update_columns(discarded_at: nil) }
          .to change { dgfip.reload.reports_transmitted_count }.from(0).to(1)
      end

      it "changes when transmitted report is deleted" do
        report = create_report(:transmitted)

        expect { report.delete }
          .to change { dgfip.reload.reports_transmitted_count }.from(1).to(0)
      end
    end

    describe "#reports_accepted_count" do
      it "doesn't change when report is transmitted" do
        report = create_report

        expect { report.update_columns(state: "transmitted") }
          .not_to change { dgfip.reload.reports_accepted_count }.from(0)
      end

      it "changes when report is accepted" do
        report = create_report(:transmitted)

        expect { report.update_columns(state: "accepted") }
          .to change { dgfip.reload.reports_accepted_count }.from(0).to(1)
      end

      it "changes when report is assigned" do
        report = create_report(:transmitted)

        expect { report.update_columns(state: "assigned") }
          .to change { dgfip.reload.reports_accepted_count }.from(0).to(1)
      end

      it "changes when report is rejected" do
        report = create_report(:transmitted)

        expect { report.update_columns(state: "rejected") }
          .not_to change { dgfip.reload.reports_accepted_count }.from(0)
      end

      it "changes when accepted report is then rejected" do
        report = create_report(:accepted)

        expect { report.update_columns(state: "rejected") }
          .to change { dgfip.reload.reports_accepted_count }.from(1).to(0)
      end

      it "doesn't change when accepted report is assigned" do
        report = create_report(:accepted)

        expect { report.update_columns(state: "assigned") }
          .not_to change { dgfip.reload.reports_accepted_count }.from(1)
      end

      it "doesn't change when resolved report is confirmed" do
        report = create_report(:applicable)

        expect { report.update_columns(state: "approved") }
          .not_to change { dgfip.reload.reports_accepted_count }.from(1)
      end

      it "changes when accepted report is discarded" do
        report = create_report(:accepted)

        expect { report.update_columns(discarded_at: Time.current) }
          .to change { dgfip.reload.reports_accepted_count }.from(1).to(0)
      end

      it "changes when accepted report is undiscarded" do
        report = create_report(:accepted, :discarded)

        expect { report.update_columns(discarded_at: nil) }
          .to change { dgfip.reload.reports_accepted_count }.from(0).to(1)
      end

      it "changes when accepted report is deleted" do
        report = create_report(:accepted)

        expect { report.delete }
          .to change { dgfip.reload.reports_accepted_count }.from(1).to(0)
      end
    end

    describe "#reports_rejected_count" do
      it "doesn't change when report is transmitted" do
        report = create_report

        expect { report.update_columns(state: "transmitted") }
          .not_to change { dgfip.reload.reports_rejected_count }.from(0)
      end

      it "changes when report is rejected" do
        report = create_report

        expect { report.update_columns(state: "rejected") }
          .to change { dgfip.reload.reports_rejected_count }.from(0).to(1)
      end

      it "doesn't change when report is accepted" do
        report = create_report

        expect { report.update_columns(state: "accepted") }
          .not_to change { dgfip.reload.reports_rejected_count }.from(0)
      end

      it "changes when rejected report is then accepted" do
        report = create_report(:rejected)

        expect { report.update_columns(state: "assigned") }
          .to change { dgfip.reload.reports_rejected_count }.from(1).to(0)
      end

      it "changes when rejected report is discarded" do
        report = create_report(:rejected)

        expect { report.update_columns(discarded_at: Time.current) }
          .to change { dgfip.reload.reports_rejected_count }.from(1).to(0)
      end

      it "changes when rejected report is undiscarded" do
        report = create_report(:rejected, :discarded)

        expect { report.update_columns(discarded_at: nil) }
          .to change { dgfip.reload.reports_rejected_count }.from(0).to(1)
      end

      it "changes when rejected report is deleted" do
        report = create_report(:rejected)

        expect { report.delete }
          .to change { dgfip.reload.reports_rejected_count }.from(1).to(0)
      end
    end

    describe "#reports_approved_count" do
      it "doesn't change when report is assigned" do
        report = create_report(:transmitted)

        expect { report.update_columns(state: "assigned") }
          .not_to change { dgfip.reload.reports_approved_count }.from(0)
      end

      it "doesn't changes when report is rejected" do
        report = create_report(:assigned)

        expect { report.update_columns(state: "rejected") }
          .not_to change { dgfip.reload.reports_approved_count }.from(0)
      end

      it "changes when applicable report is confirmed" do
        report = create_report(:applicable)

        expect { report.update_columns(state: "approved") }
          .to change { dgfip.reload.reports_approved_count }.from(0).to(1)
      end

      it "doesn't changes when inapplicable report is confirmed" do
        report = create_report(:inapplicable)

        expect { report.update_columns(state: "canceled") }
          .not_to change { dgfip.reload.reports_approved_count }.from(0)
      end

      it "changes when approved report is discarded" do
        report = create_report(:approved)

        expect { report.update_columns(discarded_at: Time.current) }
          .to change { dgfip.reload.reports_approved_count }.from(1).to(0)
      end

      it "changes when approved report is undiscarded" do
        report = create_report(:approved, :discarded)

        expect { report.update_columns(discarded_at: nil) }
          .to change { dgfip.reload.reports_approved_count }.from(0).to(1)
      end

      it "changes when approved report is deleted" do
        report = create_report(:approved)

        expect { report.delete }
          .to change { dgfip.reload.reports_approved_count }.from(1).to(0)
      end
    end

    describe "#reports_canceled_count" do
      it "doesn't change when report is assigned" do
        report = create_report(:transmitted)

        expect { report.update_columns(state: "assigned") }
          .not_to change { dgfip.reload.reports_canceled_count }.from(0)
      end

      it "doesn't changes when report is rejected" do
        report = create_report(:assigned)

        expect { report.update_columns(state: "rejected") }
          .not_to change { dgfip.reload.reports_canceled_count }.from(0)
      end

      it "changes when inapplicable report is confirmed" do
        report = create_report(:inapplicable)

        expect { report.update_columns(state: "canceled") }
          .to change { dgfip.reload.reports_canceled_count }.from(0).to(1)
      end

      it "doesn't changes when applicable report is confirmed" do
        report = create_report(:applicable)

        expect { report.update_columns(state: "approved") }
          .not_to change { dgfip.reload.reports_canceled_count }.from(0)
      end

      it "changes when canceled report is discarded" do
        report = create_report(:canceled)

        expect { report.update_columns(discarded_at: Time.current) }
          .to change { dgfip.reload.reports_canceled_count }.from(1).to(0)
      end

      it "changes when canceled report is undiscarded" do
        report = create_report(:canceled, :discarded)

        expect { report.update_columns(discarded_at: nil) }
          .to change { dgfip.reload.reports_canceled_count }.from(0).to(1)
      end

      it "changes when canceled report is deleted" do
        report = create_report(:canceled)

        expect { report.delete }
          .to change { dgfip.reload.reports_canceled_count }.from(1).to(0)
      end
    end
  end
end
