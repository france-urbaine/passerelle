# frozen_string_literal: true

require "rails_helper"

RSpec.describe Package do
  # Associations
  # ----------------------------------------------------------------------------
  describe "associations" do
    it { is_expected.to belong_to(:collectivity).required }
    it { is_expected.to belong_to(:publisher).optional }
    it { is_expected.to belong_to(:transmission).optional }
    it { is_expected.to belong_to(:ddfip).optional }
    it { is_expected.to have_many(:reports) }
  end

  # Validations
  # ----------------------------------------------------------------------------
  describe "validations" do
    it { is_expected.to validate_presence_of(:reference) }

    it "validates uniqueness of :reference" do
      create(:package)
      is_expected.to validate_uniqueness_of(:reference).ignoring_case_sensitivity
    end

    it "validates uniqueness of :reference against discarded records" do
      create(:package, :discarded)
      is_expected.to validate_uniqueness_of(:reference).ignoring_case_sensitivity
    end
  end

  # Scopes
  # ----------------------------------------------------------------------------
  describe "scopes" do
    describe ".sandbox" do
      it "scopes packages tagged as sandbox" do
        expect {
          described_class.sandbox.load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."sandbox" = TRUE
        SQL
      end
    end

    describe ".out_of_sandbox" do
      it "scopes packages by excluding those tagged as sandbox" do
        expect {
          described_class.out_of_sandbox.load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."sandbox" = FALSE
        SQL
      end
    end

    describe ".made_through_publisher_api" do
      it "scopes on packages made through publisher API" do
        expect {
          described_class.made_through_publisher_api.load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."publisher_id" IS NOT NULL
        SQL
      end
    end

    describe ".made_through_web_ui" do
      it "scopes on packages made byt the collectivity through web UI" do
        expect {
          described_class.made_through_web_ui.load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."publisher_id" IS NULL
        SQL
      end
    end

    describe ".made_by_collectivity" do
      it "scopes on packages made by one single collectivity" do
        collectivity = create(:collectivity)

        expect {
          described_class.made_by_collectivity(collectivity).load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."collectivity_id" = '#{collectivity.id}'
        SQL
      end

      it "scopes on packages made by many collectivities" do
        expect {
          described_class.made_by_collectivity(Collectivity.where(name: "A")).load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."collectivity_id" IN (
            SELECT "collectivities"."id"
            FROM   "collectivities"
            WHERE  "collectivities"."name" = 'A'
          )
        SQL
      end
    end

    describe ".made_by_publisher" do
      it "scopes on packages made by one single publisher" do
        publisher = create(:publisher)

        expect {
          described_class.made_by_publisher(publisher).load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."publisher_id" = '#{publisher.id}'
        SQL
      end

      it "scopes on packages made by many publishers" do
        expect {
          described_class.made_by_publisher(Publisher.where(name: "A")).load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."publisher_id" IN (
            SELECT "publishers"."id"
            FROM   "publishers"
            WHERE  "publishers"."name" = 'A'
          )
        SQL
      end
    end

    describe ".with_ddfip" do
      let(:ddfip) { create(:ddfip) }

      it "scopes on packages having asked ddfip" do
        expect {
          described_class.with_ddfip(ddfip).load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."ddfip_id" = '#{ddfip.id}'
        SQL
      end
    end
  end

  # Predicates
  # ----------------------------------------------------------------------------
  describe "predicates methods" do
    let_it_be(:publisher)      { build_stubbed(:publisher) }
    let_it_be(:collectivities) { build_stubbed_list(:collectivity, 2, publisher: publisher) }
    let_it_be(:packages) do
      collectivity = collectivities[0]

      [
        build_stubbed(:package, collectivity:), # 0
        build_stubbed(:package, collectivity:, publisher:), # 1
        build_stubbed(:package, :sandbox, collectivity:, publisher:), # 2
        build(:package, collectivity:), # 3
        build(:package, collectivity: collectivities[1], publisher:) # 4
      ]
    end

    describe "#out_of_sandbox?" do
      it { expect(packages[0]).to     be_out_of_sandbox }
      it { expect(packages[1]).to     be_out_of_sandbox }
      it { expect(packages[2]).not_to be_out_of_sandbox }
      it { expect(packages[3]).to     be_out_of_sandbox }
      it { expect(packages[4]).to     be_out_of_sandbox }
    end

    describe "#made_through_publisher_api?" do
      it { expect(packages[0]).not_to be_made_through_publisher_api }
      it { expect(packages[1]).to     be_made_through_publisher_api }
      it { expect(packages[3]).not_to be_made_through_publisher_api }
      it { expect(packages[4]).to     be_made_through_publisher_api }
    end

    describe "#made_through_web_ui?" do
      it { expect(packages[0]).to     be_made_through_web_ui }
      it { expect(packages[1]).not_to be_made_through_web_ui }
      it { expect(packages[3]).to     be_made_through_web_ui }
      it { expect(packages[4]).not_to be_made_through_web_ui }
    end

    describe "#made_by_collectivity?" do
      it { expect(packages[0]).to     be_made_by_collectivity(collectivities[0]) }
      it { expect(packages[1]).to     be_made_by_collectivity(collectivities[0]) }
      it { expect(packages[3]).to     be_made_by_collectivity(collectivities[0]) }
      it { expect(packages[4]).not_to be_made_by_collectivity(collectivities[0]) }
    end

    describe "#made_by_publisher?" do
      it { expect(packages[0]).not_to be_made_by_publisher(publisher) }
      it { expect(packages[1]).to     be_made_by_publisher(publisher) }
      it { expect(packages[3]).not_to be_made_by_publisher(publisher) }
      it { expect(packages[4]).to     be_made_by_publisher(publisher) }
    end
  end

  # Updates methods
  # ----------------------------------------------------------------------------
  describe "update methods" do
    describe ".reset_all_counters" do
      let_it_be(:collectivity) { create(:collectivity) }
      let_it_be(:packages)     { create_list(:package, 2, collectivity:) }

      before_all do
        create_list(:report, 1, :transmitted, collectivity:, package: packages[0])
        create_list(:report, 2, :approved,    collectivity:, package: packages[0])
        create_list(:report, 3, :rejected,    collectivity:, package: packages[0])
        create_list(:report, 1, :assigned,    collectivity:, package: packages[1])

        Package.update_all(
          reports_count:          99,
          reports_approved_count: 99,
          reports_rejected_count: 99
        )
      end

      it "performs a single SQL function" do
        expect { described_class.reset_all_counters }
          .to perform_sql_query("SELECT reset_all_packages_counters()")
      end

      it "returns the number of concerned packages" do
        expect(described_class.reset_all_counters).to eq(2)
      end

      it "updates #reports_count" do
        expect {
          described_class.reset_all_counters
        }.to   change { packages[0].reload.reports_count }.to(6)
          .and change { packages[1].reload.reports_count }.to(1)
      end

      it "updates #reports_approved_count" do
        expect {
          described_class.reset_all_counters
        }.to   change { packages[0].reload.reports_approved_count }.to(2)
          .and change { packages[1].reload.reports_approved_count }.to(0)
      end

      it "updates #reports_rejected_count" do
        expect {
          described_class.reset_all_counters
        }.to   change { packages[0].reload.reports_rejected_count }.to(3)
          .and change { packages[1].reload.reports_rejected_count }.to(0)
      end
    end
  end

  # Database constraints and triggers
  # ----------------------------------------------------------------------------
  describe "database constraints" do
    it "asserts the uniqueness of reference" do
      existing_package = create(:package, reference: "2023-05-0003")
      another_package  = build(:package, reference: existing_package.reference)

      expect { another_package.save(validate: false) }
        .to raise_error(ActiveRecord::RecordNotUnique).with_message(/PG::UniqueViolation/)
    end
  end

  describe "database triggers" do
    let!(:collectivity) { create(:collectivity) }
    let!(:package)      { create(:package, collectivity:) }
    let(:report)        { create(:report, collectivity:, package:) }

    describe "#reports_count" do
      it "changes when report is created" do
        expect { report }
          .to change { package.reload.reports_count }.from(0).to(1)
      end

      it "changes when report is assigned to another package" do
        report
        another_package = create(:package, collectivity:)

        expect { report.update(package: another_package) }
          .to change { package.reload.reports_count }.from(1).to(0)
      end

      it "changes when report is discarded" do
        report

        expect { report.discard }
          .to change { package.reload.reports_count }.from(1).to(0)
      end

      it "changes when report is undiscarded" do
        report.discard

        expect { report.undiscard }
          .to change { package.reload.reports_count }.from(0).to(1)
      end

      it "changes when report is deleted" do
        report

        expect { report.destroy }
          .to change { package.reload.reports_count }.from(1).to(0)
      end
    end

    describe "#reports_approved_count" do
      it "doesn't change report is created" do
        expect { report }
          .not_to change { package.reload.reports_approved_count }.from(0)
      end

      it "doesn't changes when report is rejected" do
        report

        expect { report.reject! }
          .not_to change { package.reload.reports_approved_count }.from(0)
      end

      it "changes when report is approved" do
        report

        expect { report.approve! }
          .to change { package.reload.reports_approved_count }.from(0).to(1)
      end

      it "changes when approved report is reseted" do
        report.approve!

        expect { report.update(state: :processing) }
          .to change { package.reload.reports_approved_count }.from(1).to(0)
      end

      it "changes when approved report is rejected" do
        report.approve!

        expect { report.reject! }
          .to change { package.reload.reports_approved_count }.from(1).to(0)
      end
    end

    describe "#reports_rejected_count" do
      it "doesn't change report is created" do
        expect { report }
          .not_to change { package.reload.reports_rejected_count }.from(0)
      end

      it "doesn't changes when report is approved" do
        report

        expect { report.approve! }
          .not_to change { package.reload.reports_rejected_count }.from(0)
      end

      it "changes when report is rejected" do
        report

        expect { report.reject! }
          .to change { package.reload.reports_rejected_count }.from(0).to(1)
      end

      it "changes when rejected report is reseted" do
        report.reject!

        expect { report.update(state: :processing) }
          .to change { package.reload.reports_rejected_count }.from(1).to(0)
      end

      it "changes when rejected report is approved" do
        report.reject!

        expect { report.approve! }
          .to change { package.reload.reports_rejected_count }.from(1).to(0)
      end
    end
  end
end
