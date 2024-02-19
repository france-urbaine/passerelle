# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publisher do
  # Associations
  # ----------------------------------------------------------------------------
  describe "associations" do
    it { is_expected.to have_many(:users) }
    it { is_expected.to have_many(:collectivities) }
    it { is_expected.to have_many(:transmissions) }
    it { is_expected.to have_many(:packages) }
    it { is_expected.to have_many(:reports) }
    it { is_expected.to have_many(:oauth_applications) }
  end

  # Validations
  # ----------------------------------------------------------------------------
  describe "validations" do
    subject { build(:publisher) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:siren) }

    it { is_expected.to     allow_value("801453893").for(:siren) }
    it { is_expected.not_to allow_value("1234567AB").for(:siren) }
    it { is_expected.not_to allow_value("1234567891").for(:siren) }

    it { is_expected.to     allow_value("foo@bar.com")        .for(:contact_email) }
    it { is_expected.to     allow_value("foo@bar")            .for(:contact_email) }
    it { is_expected.to     allow_value("foo@bar-bar.bar.com").for(:contact_email) }
    it { is_expected.not_to allow_value("foo.bar.com")        .for(:contact_email) }

    it "validates uniqueness of :siren & :name" do
      create(:publisher)

      aggregate_failures do
        is_expected.to validate_uniqueness_of(:siren).ignoring_case_sensitivity
        is_expected.to validate_uniqueness_of(:name).ignoring_case_sensitivity
      end
    end

    it "ignores discarded records when validating uniqueness of :siren & :name" do
      create(:publisher, :discarded)

      aggregate_failures do
        is_expected.not_to validate_uniqueness_of(:siren).ignoring_case_sensitivity
        is_expected.not_to validate_uniqueness_of(:name).ignoring_case_sensitivity
      end
    end

    it "raises an exception when undiscarding a record when its attributes is already used by other records" do
      discarded_publishers = create_list(:publisher, 2, :discarded)
      create(:publisher, siren: discarded_publishers[0].siren, name: discarded_publishers[1].name)

      aggregate_failures do
        expect { discarded_publishers[0].undiscard }.to raise_error(ActiveRecord::RecordNotUnique)
        expect { discarded_publishers[1].undiscard }.to raise_error(ActiveRecord::RecordNotUnique)
      end
    end
  end

  # Scopes
  # ----------------------------------------------------------------------------
  describe "scopes" do
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
  end

  # Scopes: orders
  # ----------------------------------------------------------------------------
  describe "order scopes" do
    describe ".order_by_param" do
      it "sorts publishers by name" do
        expect {
          described_class.order_by_param("name").load
        }.to perform_sql_query(<<~SQL)
          SELECT    "publishers".*
          FROM      "publishers"
          ORDER BY  UNACCENT("publishers"."name") ASC NULLS LAST,
                    "publishers"."created_at" ASC
        SQL
      end

      it "sorts publishers by name in reversed order" do
        expect {
          described_class.order_by_param("-name").load
        }.to perform_sql_query(<<~SQL)
          SELECT    "publishers".*
          FROM      "publishers"
          ORDER BY  UNACCENT("publishers"."name") DESC NULLS FIRST,
                    "publishers"."created_at" DESC
        SQL
      end

      it "sorts publishers by SIREN" do
        expect {
          described_class.order_by_param("siren").load
        }.to perform_sql_query(<<~SQL)
          SELECT    "publishers".*
          FROM      "publishers"
          ORDER BY  "publishers"."siren" ASC,
                    "publishers"."created_at" ASC
        SQL
      end

      it "sorts publishers by SIREN in reversed order" do
        expect {
          described_class.order_by_param("-siren").load
        }.to perform_sql_query(<<~SQL)
          SELECT    "publishers".*
          FROM      "publishers"
          ORDER BY  "publishers"."siren" DESC,
                    "publishers"."created_at" DESC
        SQL
      end
    end

    describe ".order_by_score" do
      it "sorts publishers by search score" do
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

    describe ".order_by_name" do
      it "sorts publishers by name without argument" do
        expect {
          described_class.order_by_name.load
        }.to perform_sql_query(<<~SQL)
          SELECT   "publishers".*
          FROM     "publishers"
          ORDER BY UNACCENT("publishers"."name") ASC  NULLS LAST
        SQL
      end

      it "sorts publishers by name in ascending order" do
        expect {
          described_class.order_by_name(:asc).load
        }.to perform_sql_query(<<~SQL)
          SELECT   "publishers".*
          FROM     "publishers"
          ORDER BY UNACCENT("publishers"."name") ASC  NULLS LAST
        SQL
      end

      it "sorts publishers by name in descending order" do
        expect {
          described_class.order_by_name(:desc).load
        }.to perform_sql_query(<<~SQL)
          SELECT   "publishers".*
          FROM     "publishers"
          ORDER BY UNACCENT("publishers"."name") DESC  NULLS FIRST
        SQL
      end
    end

    describe ".order_by_siren" do
      it "sorts publishers by SIREN without argument" do
        expect {
          described_class.order_by_siren.load
        }.to perform_sql_query(<<~SQL)
          SELECT   "publishers".*
          FROM     "publishers"
          ORDER BY "publishers"."siren" ASC
        SQL
      end

      it "sorts publishers by SIREN in ascending order" do
        expect {
          described_class.order_by_siren(:asc).load
        }.to perform_sql_query(<<~SQL)
          SELECT   "publishers".*
          FROM     "publishers"
          ORDER BY "publishers"."siren" ASC
        SQL
      end

      it "sorts publishers by SIREN in descending order" do
        expect {
          described_class.order_by_siren(:desc).load
        }.to perform_sql_query(<<~SQL)
          SELECT   "publishers".*
          FROM     "publishers"
          ORDER BY "publishers"."siren" DESC
        SQL
      end
    end
  end

  # Updates methods
  # ----------------------------------------------------------------------------
  describe "update methods" do
    describe ".reset_all_counters" do
      let_it_be(:publishers) { create_list(:publisher, 2) }

      it "performs a single SQL function" do
        expect { described_class.reset_all_counters }
          .to perform_sql_query("SELECT reset_all_publishers_counters()")
      end

      it "returns the number of concerned publishers" do
        expect(described_class.reset_all_counters).to eq(2)
      end

      describe "users counts" do
        before_all do
          create_list(:user, 2)
          create_list(:user, 4, organization: publishers[0])
          create_list(:user, 2, organization: publishers[1])
          create(:user, :discarded, organization: publishers[0])

          Publisher.update_all(users_count: 99)
        end

        it "updates #users_count" do
          expect {
            described_class.reset_all_counters
          }.to change { publishers[0].reload.users_count }.to(4)
            .and change { publishers[1].reload.users_count }.to(2)
        end
      end

      describe "collectivities counts" do
        before_all do
          create_list(:collectivity, 2)
          create_list(:collectivity, 2, publisher: publishers[0])
          create_list(:collectivity, 4, publisher: publishers[1])
          create(:collectivity, :discarded, publisher: publishers[0])

          Publisher.update_all(collectivities_count: 99)
        end

        it "updates #collectivities_count" do
          expect {
            described_class.reset_all_counters
          }.to change { publishers[0].reload.collectivities_count }.to(2)
            .and change { publishers[1].reload.collectivities_count }.to(4)
        end
      end

      describe "reports counts" do
        before_all do
          publishers[0].tap do |publisher|
            create(:collectivity, :with_users, publisher:, users_size: 1).tap do |collectivity|
              create(:report, :ready, collectivity:)
              create(:report, :transmitted_through_web_ui, collectivity:)
              create(:report, :assigned, collectivity:)
              create(:report, :applicable, collectivity:)
              create(:report, :approved, collectivity:)
              create(:report, :canceled, collectivity:)
              create(:report, :rejected, collectivity:)
              create(:report, :made_through_api, :ready, collectivity:, publisher:)
              create(:report, :transmitted_to_sandbox, collectivity:, publisher:)
              create(:report, :transmitted_through_api, collectivity:, publisher:)
              create(:report, :transmitted_through_api, :assigned, collectivity:, publisher:)
              create(:report, :transmitted_through_api, :applicable, collectivity:, publisher:)
              create(:report, :transmitted_through_api, :approved, collectivity:, publisher:)
              create(:report, :transmitted_through_api, :canceled, collectivity:, publisher:)
              create(:report, :transmitted_through_api, :rejected, collectivity:, publisher:)
            end
          end

          publishers[1].tap do |publisher|
            create(:collectivity, publisher:).tap do |collectivity|
              create(:report, :transmitted_through_api, :canceled, collectivity:, publisher:)
            end
          end

          Publisher.update_all(
            reports_transmitted_count: 99,
            reports_accepted_count:    99,
            reports_rejected_count:    99,
            reports_approved_count:    99,
            reports_canceled_count:    99,
            reports_returned_count:    99
          )
        end

        it "updates #reports_transmitted_count" do
          expect {
            described_class.reset_all_counters
          }.to   change { publishers[0].reload.reports_transmitted_count }.to(6)
            .and change { publishers[1].reload.reports_transmitted_count }.to(1)
        end

        it "updates #reports_accepted_count" do
          expect {
            described_class.reset_all_counters
          }.to   change { publishers[0].reload.reports_accepted_count }.to(4)
            .and change { publishers[1].reload.reports_accepted_count }.to(1)
        end

        it "updates #reports_rejected_count" do
          expect {
            described_class.reset_all_counters
          }.to   change { publishers[0].reload.reports_rejected_count }.to(1)
            .and change { publishers[1].reload.reports_rejected_count }.to(0)
        end

        it "updates #reports_approved_count" do
          expect {
            described_class.reset_all_counters
          }.to   change { publishers[0].reload.reports_approved_count }.to(1)
            .and change { publishers[1].reload.reports_approved_count }.to(0)
        end

        it "updates #reports_canceled_count" do
          expect {
            described_class.reset_all_counters
          }.to   change { publishers[0].reload.reports_canceled_count }.to(1)
            .and change { publishers[1].reload.reports_canceled_count }.to(1)
        end

        it "updates #reports_returned_count" do
          expect {
            described_class.reset_all_counters
          }.to change { publishers[0].reload.reports_returned_count }.to(3)
            .and change { publishers[1].reload.reports_returned_count }.to(1)
        end
      end
    end
  end

  # Database constraints and triggers
  # ----------------------------------------------------------------------------
  describe "database triggers" do
    let!(:publisher) { create(:publisher) }

    def create_user(*traits, **attributes)
      create(:user, *traits, organization: publisher, **attributes)
    end

    describe "#users_count" do
      it "changes on creation" do
        expect { create_user }
          .to change { publisher.reload.users_count }.from(0).to(1)
      end

      it "changes on deletion" do
        user = create_user

        expect { user.delete }
          .to change { publisher.reload.users_count }.from(1).to(0)
      end

      it "changes when user is discarded" do
        user = create_user

        expect { user.update_columns(discarded_at: Time.current) }
          .to change { publisher.reload.users_count }.from(1).to(0)
      end

      it "changes when user is undiscarded" do
        user = create_user(:discarded)

        expect { user.update_columns(discarded_at: nil) }
          .to change { publisher.reload.users_count }.from(0).to(1)
      end

      it "changes when user switches to another organization" do
        user = create_user
        another_publisher = create(:publisher)

        expect { user.update_columns(organization_id: another_publisher.id) }
          .to change { publisher.reload.users_count }.from(1).to(0)
      end
    end

    describe "#collectivities_count" do
      let(:collectivity) { create(:collectivity, publisher:) }

      it "changes on creation" do
        expect { collectivity }
          .to change { publisher.reload.collectivities_count }.from(0).to(1)
      end

      it "changes on deletion" do
        collectivity

        expect { collectivity.destroy }
          .to change { publisher.reload.collectivities_count }.from(1).to(0)
      end

      it "changes when user is discarded" do
        collectivity

        expect { collectivity.discard }
          .to change { publisher.reload.collectivities_count }.from(1).to(0)
      end

      it "changes when collectivity is undiscarded" do
        collectivity.discard

        expect { collectivity.undiscard }
          .to change { publisher.reload.collectivities_count }.from(0).to(1)
      end

      it "changes when collectivity switches to another publisher" do
        collectivity
        another_publisher = create(:publisher)

        expect { collectivity.update(publisher: another_publisher) }
          .to change { publisher.reload.collectivities_count }.from(1).to(0)
      end
    end

    def create_report(*traits, **attributes)
      create(:report, :made_through_api, *traits, publisher:, **attributes)
    end

    describe "#reports_transmitted_count" do
      it "doesn't change when report is created" do
        expect { create_report }
          .not_to change { publisher.reload.reports_transmitted_count }.from(0)
      end

      it "changes when report is transmitted" do
        report = create_report

        expect { report.update_columns(state: "transmitted") }
          .to change { publisher.reload.reports_transmitted_count }.from(0).to(1)
      end

      it "doesn't change when report is transmitted to a sandbox" do
        report = create_report

        expect { report.update_columns(state: "transmitted", sandbox: true) }
          .not_to change { publisher.reload.reports_transmitted_count }.from(0)
      end

      it "doesn't change when report is transmitted through WEB UI" do
        report = create_report(:made_through_web_ui, publisher: nil)

        expect { report.update_columns(state: "transmitted") }
          .not_to change { publisher.reload.reports_transmitted_count }.from(0)
      end

      it "doesn't change when transmitted report is assigned" do
        report = create_report(:transmitted)

        expect { report.update_columns(state: "assigned") }
          .not_to change { publisher.reload.reports_transmitted_count }.from(1)
      end

      it "changes when transmitted report is discarded" do
        report = create_report(:transmitted)

        expect { report.update_columns(discarded_at: Time.current) }
          .to change { publisher.reload.reports_transmitted_count }.from(1).to(0)
      end

      it "changes when transmitted report is undiscarded" do
        report = create_report(:transmitted, :discarded)

        expect { report.update_columns(discarded_at: nil) }
          .to change { publisher.reload.reports_transmitted_count }.from(0).to(1)
      end

      it "changes when transmitted report is deleted" do
        report = create_report(:transmitted)

        expect { report.delete }
          .to change { publisher.reload.reports_transmitted_count }.from(1).to(0)
      end
    end

    describe "#reports_accepted_count" do
      it "doesn't change when report is transmitted" do
        report = create_report

        expect { report.update_columns(state: "transmitted") }
          .not_to change { publisher.reload.reports_accepted_count }.from(0)
      end

      it "changes when report is accepted" do
        report = create_report(:transmitted)

        expect { report.update_columns(state: "accepted") }
          .to change { publisher.reload.reports_accepted_count }.from(0).to(1)
      end

      it "changes when report is assigned" do
        report = create_report(:transmitted)

        expect { report.update_columns(state: "assigned") }
          .to change { publisher.reload.reports_accepted_count }.from(0).to(1)
      end

      it "changes when report is rejected" do
        report = create_report(:transmitted)

        expect { report.update_columns(state: "rejected") }
          .not_to change { publisher.reload.reports_accepted_count }.from(0)
      end

      it "changes when accepted report is then rejected" do
        report = create_report(:accepted)

        expect { report.update_columns(state: "rejected") }
          .to change { publisher.reload.reports_accepted_count }.from(1).to(0)
      end

      it "doesn't change when accepted report is assigned" do
        report = create_report(:accepted)

        expect { report.update_columns(state: "assigned") }
          .not_to change { publisher.reload.reports_accepted_count }.from(1)
      end

      it "doesn't change when resolved report is confirmed" do
        report = create_report(:applicable)

        expect { report.update_columns(state: "approved") }
          .not_to change { publisher.reload.reports_accepted_count }.from(1)
      end

      it "changes when accepted report is discarded" do
        report = create_report(:accepted)

        expect { report.update_columns(discarded_at: Time.current) }
          .to change { publisher.reload.reports_accepted_count }.from(1).to(0)
      end

      it "changes when accepted report is undiscarded" do
        report = create_report(:accepted, :discarded)

        expect { report.update_columns(discarded_at: nil) }
          .to change { publisher.reload.reports_accepted_count }.from(0).to(1)
      end

      it "changes when accepted report is deleted" do
        report = create_report(:accepted)

        expect { report.delete }
          .to change { publisher.reload.reports_accepted_count }.from(1).to(0)
      end
    end

    describe "#reports_rejected_count" do
      it "doesn't change when report is transmitted" do
        report = create_report

        expect { report.update_columns(state: "transmitted") }
          .not_to change { publisher.reload.reports_rejected_count }.from(0)
      end

      it "changes when report is rejected" do
        report = create_report

        expect { report.update_columns(state: "rejected") }
          .to change { publisher.reload.reports_rejected_count }.from(0).to(1)
      end

      it "doesn't change when report is accepted" do
        report = create_report

        expect { report.update_columns(state: "accepted") }
          .not_to change { publisher.reload.reports_rejected_count }.from(0)
      end

      it "changes when rejected report is then accepted" do
        report = create_report(:rejected)

        expect { report.update_columns(state: "assigned") }
          .to change { publisher.reload.reports_rejected_count }.from(1).to(0)
      end

      it "changes when rejected report is discarded" do
        report = create_report(:rejected)

        expect { report.update_columns(discarded_at: Time.current) }
          .to change { publisher.reload.reports_rejected_count }.from(1).to(0)
      end

      it "changes when rejected report is undiscarded" do
        report = create_report(:rejected, :discarded)

        expect { report.update_columns(discarded_at: nil) }
          .to change { publisher.reload.reports_rejected_count }.from(0).to(1)
      end

      it "changes when rejected report is deleted" do
        report = create_report(:rejected)

        expect { report.delete }
          .to change { publisher.reload.reports_rejected_count }.from(1).to(0)
      end
    end

    describe "#reports_approved_count" do
      it "doesn't change when report is assigned" do
        report = create_report(:transmitted)

        expect { report.update_columns(state: "assigned") }
          .not_to change { publisher.reload.reports_approved_count }.from(0)
      end

      it "doesn't changes when report is rejected" do
        report = create_report(:assigned)

        expect { report.update_columns(state: "rejected") }
          .not_to change { publisher.reload.reports_approved_count }.from(0)
      end

      it "changes when applicable report is confirmed" do
        report = create_report(:applicable)

        expect { report.update_columns(state: "approved") }
          .to change { publisher.reload.reports_approved_count }.from(0).to(1)
      end

      it "doesn't changes when inapplicable report is confirmed" do
        report = create_report(:inapplicable)

        expect { report.update_columns(state: "canceled") }
          .not_to change { publisher.reload.reports_approved_count }.from(0)
      end

      it "changes when approved report is discarded" do
        report = create_report(:approved)

        expect { report.update_columns(discarded_at: Time.current) }
          .to change { publisher.reload.reports_approved_count }.from(1).to(0)
      end

      it "changes when approved report is undiscarded" do
        report = create_report(:approved, :discarded)

        expect { report.update_columns(discarded_at: nil) }
          .to change { publisher.reload.reports_approved_count }.from(0).to(1)
      end

      it "changes when approved report is deleted" do
        report = create_report(:approved)

        expect { report.delete }
          .to change { publisher.reload.reports_approved_count }.from(1).to(0)
      end
    end

    describe "#reports_canceled_count" do
      it "doesn't change when report is assigned" do
        report = create_report(:transmitted)

        expect { report.update_columns(state: "assigned") }
          .not_to change { publisher.reload.reports_canceled_count }.from(0)
      end

      it "doesn't changes when report is rejected" do
        report = create_report(:assigned)

        expect { report.update_columns(state: "rejected") }
          .not_to change { publisher.reload.reports_canceled_count }.from(0)
      end

      it "changes when inapplicable report is confirmed" do
        report = create_report(:inapplicable)

        expect { report.update_columns(state: "canceled") }
          .to change { publisher.reload.reports_canceled_count }.from(0).to(1)
      end

      it "doesn't changes when applicable report is confirmed" do
        report = create_report(:applicable)

        expect { report.update_columns(state: "approved") }
          .not_to change { publisher.reload.reports_canceled_count }.from(0)
      end

      it "changes when canceled report is discarded" do
        report = create_report(:canceled)

        expect { report.update_columns(discarded_at: Time.current) }
          .to change { publisher.reload.reports_canceled_count }.from(1).to(0)
      end

      it "changes when canceled report is undiscarded" do
        report = create_report(:canceled, :discarded)

        expect { report.update_columns(discarded_at: nil) }
          .to change { publisher.reload.reports_canceled_count }.from(0).to(1)
      end

      it "changes when canceled report is deleted" do
        report = create_report(:canceled)

        expect { report.delete }
          .to change { publisher.reload.reports_canceled_count }.from(1).to(0)
      end
    end

    describe "#reports_returned_count" do
      it "doesn't change when report is assigned" do
        report = create_report(:transmitted)

        expect { report.update_columns(state: "assigned") }
          .not_to change { publisher.reload.reports_returned_count }.from(0)
      end

      it "changes when report is rejected" do
        report = create_report(:assigned)

        expect { report.update_columns(state: "rejected") }
          .to change { publisher.reload.reports_returned_count }.from(0).to(1)
      end

      it "changes when inapplicable report is confirmed" do
        report = create_report(:inapplicable)

        expect { report.update_columns(state: "canceled") }
          .to change { publisher.reload.reports_returned_count }.from(0).to(1)
      end

      it "doesn't changes when applicable report is confirmed" do
        report = create_report(:applicable)

        expect { report.update_columns(state: "approved") }
          .to change { publisher.reload.reports_returned_count }.from(0).to(1)
      end

      it "changes when returned report is discarded" do
        report = create_report(:canceled)

        expect { report.update_columns(discarded_at: Time.current) }
          .to change { publisher.reload.reports_returned_count }.from(1).to(0)
      end

      it "changes when returned report is undiscarded" do
        report = create_report(:canceled, :discarded)

        expect { report.update_columns(discarded_at: nil) }
          .to change { publisher.reload.reports_returned_count }.from(0).to(1)
      end

      it "changes when returned report is deleted" do
        report = create_report(:canceled)

        expect { report.delete }
          .to change { publisher.reload.reports_returned_count }.from(1).to(0)
      end
    end
  end
end
