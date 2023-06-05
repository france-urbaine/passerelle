# frozen_string_literal: true

require "rails_helper"

RSpec.describe Package do
  # Associations
  # ----------------------------------------------------------------------------
  describe "associations" do
    it { is_expected.to belong_to(:collectivity).required }
    it { is_expected.to belong_to(:publisher).optional }
    it { is_expected.to have_many(:reports) }
  end

  # Validations
  # ----------------------------------------------------------------------------
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:action) }
    it { is_expected.to validate_inclusion_of(:action).in_array(Report::ACTIONS) }
  end

  # Database constraints
  # ----------------------------------------------------------------------------
  describe "database contraints" do
    let_it_be(:package) do
      create(:package, action: "evaluation_hab", reference: "2023-05-0003")
    end

    it "asserts the uniqueness of reference" do
      expect {
        create(:package, reference: "2023-05-0003")
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "asserts an action is allowed by not triggering DB constraints" do
      expect {
        package.update_column(:action, "evaluation_eco")
      }.not_to raise_error
    end

    it "asserts an action is not allowed by triggering DB constraints" do
      expect {
        package.update_column(:action, "evaluation_cfe")
      }.to raise_error(ActiveRecord::StatementInvalid)
    end
  end

  # Scopes
  # ----------------------------------------------------------------------------
  describe "scopes" do
    describe ".packing" do
      it "scopes packages not yet transmitted" do
        expect {
          described_class.packing.load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."transmitted_at" IS NULL
        SQL
      end
    end

    describe ".transmitted" do
      it "scopes on transmitted packages" do
        expect {
          described_class.transmitted.load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."transmitted_at" IS NOT NULL
        SQL
      end
    end

    describe ".to_approve" do
      it "scopes on transmitted and undiscarded packages waiting for approval" do
        expect {
          described_class.to_approve.load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."transmitted_at" IS NOT NULL
            AND  "packages"."discarded_at" IS NULL
            AND  "packages"."approved_at" IS NULL
            AND  "packages"."rejected_at" IS NULL
        SQL
      end
    end

    describe ".approved" do
      it "scopes on packages approved by a DDFIP" do
        expect {
          described_class.approved.load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."transmitted_at" IS NOT NULL
            AND  "packages"."approved_at" IS NOT NULL
            AND  "packages"."rejected_at" IS NULL
        SQL
      end
    end

    describe ".rejected" do
      it "scopes on packages rejected by a DDFIP" do
        expect {
          described_class.rejected.load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."transmitted_at" IS NOT NULL
            AND  "packages"."rejected_at" IS NOT NULL
        SQL
      end
    end

    describe ".unrejected" do
      it "scopes on packages rejected by a DDFIP" do
        expect {
          described_class.unrejected.load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."transmitted_at" IS NOT NULL
            AND  "packages"."rejected_at" IS NULL
        SQL
      end
    end

    describe ".packed_through_publisher_api" do
      it "scopes on packages packed through publisher API" do
        expect {
          described_class.packed_through_publisher_api.load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."publisher_id" IS NOT NULL
        SQL
      end
    end

    describe ".packed_through_collectivity_ui" do
      it "scopes on packages packed through collectivity UI" do
        expect {
          described_class.packed_through_collectivity_ui.load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."publisher_id" IS NULL
        SQL
      end
    end

    describe ".sent_by_collectivity" do
      it "scopes on packages sent by one single collectivity" do
        collectivity = create(:collectivity)

        expect {
          described_class.sent_by_collectivity(collectivity).load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."collectivity_id" = '#{collectivity.id}'
        SQL
      end

      it "scopes on packages sent by many collectivities" do
        expect {
          described_class.sent_by_collectivity(Collectivity.where(name: "A")).load
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

    describe ".sent_by_publisher" do
      it "scopes on packages sent by one single publisher" do
        publisher = create(:publisher)

        expect {
          described_class.sent_by_publisher(publisher).load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."publisher_id" = '#{publisher.id}'
        SQL
      end

      it "scopes on packages sent by many publishers" do
        expect {
          described_class.sent_by_publisher(Publisher.where(name: "A")).load
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

    describe ".sent_by" do
      it "scopes on packages sent by one single collectivity" do
        collectivity = create(:collectivity)

        expect {
          described_class.sent_by(collectivity).load
        }.to send_message(described_class, :sent_by_collectivity).with(collectivity)
      end

      it "scopes on packages sent by many collectivities" do
        collectivities = Collectivity.where(name: "A")

        expect {
          described_class.sent_by(collectivities).load
        }.to send_message(described_class, :sent_by_collectivity).with(collectivities)
      end

      it "scopes on packages sent by one single publisher" do
        publisher = create(:publisher)

        expect {
          described_class.sent_by(publisher).load
        }.to send_message(described_class, :sent_by_publisher).with(publisher)
      end

      it "scopes on packages sent by many publishers" do
        publishers = Publisher.where(name: "A")

        expect {
          described_class.sent_by(publishers).load
        }.to send_message(described_class, :sent_by_publisher).with(publishers)
      end

      it "raises an TypeError with unexpected argument" do
        expect {
          described_class.sent_by(User.all).load
        }.to raise_error(TypeError)
      end
    end

    describe ".with_reports" do
      it "scopes on packages having reports" do
        expect {
          described_class.with_reports.load
        }.to perform_sql_query(<<~SQL)
          SELECT     DISTINCT "packages".*
          FROM       "packages"
          INNER JOIN "reports" ON "reports"."package_id" = "packages"."id"
          WHERE      "reports"."discarded_at" IS NULL
        SQL
      end

      it "scopes on packages includings the given reports" do
        expect {
          described_class.with_reports(Report.sandbox).load
        }.to perform_sql_query(<<~SQL)
          SELECT     DISTINCT "packages".*
          FROM       "packages"
          INNER JOIN "reports" ON "reports"."package_id" = "packages"."id"
          WHERE      "reports"."sandbox" = TRUE
            AND      "reports"."discarded_at" IS NULL
        SQL
      end
    end

    describe ".available_to_collectivity" do
      it "scopes on packages available to a collectivity" do
        collectivity = create(:collectivity)

        expect {
          described_class.available_to_collectivity(collectivity).load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."discarded_at" IS NULL
            AND  "packages"."collectivity_id" = '#{collectivity.id}'
            AND  ("packages"."transmitted_at" IS NOT NULL OR "packages"."publisher_id" IS NULL)
        SQL
      end
    end

    describe ".available_to_publisher" do
      it "scopes on packages available to a publisher" do
        publisher = create(:publisher)

        expect {
          described_class.available_to_publisher(publisher).load
        }.to perform_sql_query(<<~SQL)
          SELECT "packages".*
          FROM   "packages"
          WHERE  "packages"."discarded_at" IS NULL
            AND  "packages"."publisher_id" = '#{publisher.id}'
        SQL
      end
    end

    describe ".available_to_ddfip" do
      it "scopes on packages available to a DDIP" do
        departement = create(:departement, code_departement: "64")
        ddfip       = create(:ddfip, departement: departement)

        expect {
          described_class.available_to_ddfip(ddfip).load
        }.to perform_sql_query(<<~SQL)
          SELECT     DISTINCT "packages".*
          FROM       "packages"
          INNER JOIN "reports" ON "reports"."package_id" = "packages"."id"
          INNER JOIN "communes" ON "communes"."code_insee" = "reports"."code_insee"
          WHERE      "packages"."discarded_at" IS NULL
            AND      "packages"."transmitted_at" IS NOT NULL
            AND      "packages"."rejected_at" IS NULL
            AND      "communes"."code_departement" = '64'
            AND      "reports"."discarded_at" IS NULL
        SQL
      end
    end

    describe ".available_to_office" do
      it "scopes on packages available to an Office" do
        office = create(:office, action: "evaluation_hab")

        expect {
          described_class.available_to_office(office).load
        }.to perform_sql_query(<<~SQL)
          SELECT     DISTINCT "packages".*
          FROM       "packages"
          INNER JOIN "reports" ON "reports"."package_id" = "packages"."id"
          INNER JOIN "office_communes" ON "office_communes"."code_insee" = "reports"."code_insee"
          WHERE      "packages"."discarded_at" IS NULL
            AND      "packages"."transmitted_at" IS NOT NULL
            AND      "packages"."approved_at" IS NOT NULL
            AND      "packages"."rejected_at" IS NULL
            AND      "office_communes"."office_id" = '#{office.id}'
            AND      "reports"."action" = 'evaluation_hab'
            AND      "reports"."discarded_at" IS NULL
        SQL
      end
    end

    describe ".available_to" do
      it "scopes reports available to a publisher" do
        publisher = create(:publisher)

        expect {
          described_class.available_to(publisher).load
        }.to send_message(described_class, :available_to_publisher).with(publisher)
      end

      it "scopes reports available to a collectivity" do
        collectivity = create(:collectivity)

        expect {
          described_class.available_to(collectivity).load
        }.to send_message(described_class, :available_to_collectivity).with(collectivity)
      end

      it "scopes reports available to a ddfip" do
        ddfip = create(:ddfip)

        expect {
          described_class.available_to(ddfip).load
        }.to send_message(described_class, :available_to_ddfip).with(ddfip)
      end

      it "scopes reports available to a office" do
        office = create(:office)

        expect {
          described_class.available_to(office).load
        }.to send_message(described_class, :available_to_office).with(office)
      end

      it "raises an TypeError with unexpected argument" do
        expect {
          described_class.available_to(User.all).load
        }.to raise_error(TypeError)
      end
    end
  end

  # Callbacks
  # ----------------------------------------------------------------------------
  describe "callbacks" do
    describe "#generate_reference" do
      # Use only one collectivity to reduce the number of queries and records to create
      let_it_be(:collectivities) { create_list(:collectivity, 3) }

      def create_package
        create(:package, collectivity: collectivities.sample)
      end

      it "increments the reference for every package created the same month" do
        aggregate_failures do
          Timecop.travel(Time.zone.local(2023, 5, 26))
          expect(create_package).to have_attributes(reference: "2023-05-00001")
          expect(create_package).to have_attributes(reference: "2023-05-00002")
          expect(create_package).to have_attributes(reference: "2023-05-00003")

          Timecop.travel(Time.zone.local(2023, 5, 30))
          expect(create_package).to have_attributes(reference: "2023-05-00004")
        end
      end

      it "starts again references to 1 next month" do
        aggregate_failures do
          Timecop.travel(Time.zone.local(2023, 5, 26))
          expect(create_package).to have_attributes(reference: "2023-05-00001")
          expect(create_package).to have_attributes(reference: "2023-05-00002")

          Timecop.travel(Time.zone.local(2023, 6, 1))
          expect(create_package).to have_attributes(reference: "2023-06-00001")
        end
      end
    end
  end

  # Predicates
  # ----------------------------------------------------------------------------
  describe "predicates" do
    let_it_be(:packages) do
      # Use only one publisher & collectivity to reduce the number of queries and
      # records to create
      publisher = build(:publisher)
      collectivity = build(:collectivity, publisher: publisher)

      [
        build(:package, collectivity: collectivity),
        build(:package, :transmitted, collectivity: collectivity, publisher: publisher),
        build(:package, :approved, collectivity: collectivity),
        build(:package, :rejected, collectivity: collectivity),
        build(:package, :approved, :rejected, collectivity: collectivity)
      ]
    end

    describe "#packing?" do
      it { expect(packages[0]).to be_packing }
      it { expect(packages[1]).not_to be_packing }
      it { expect(packages[2]).not_to be_packing }
      it { expect(packages[3]).not_to be_packing }
      it { expect(packages[4]).not_to be_packing }
    end

    describe "#transmitted?" do
      it { expect(packages[0]).not_to be_transmitted }
      it { expect(packages[1]).to be_transmitted }
      it { expect(packages[2]).to be_transmitted }
      it { expect(packages[3]).to be_transmitted }
      it { expect(packages[4]).to be_transmitted }
    end

    describe "#packed_through_publisher_api?" do
      it { expect(packages[0]).not_to be_packed_through_publisher_api }
      it { expect(packages[1]).to be_packed_through_publisher_api }
      it { expect(packages[2]).not_to be_packed_through_publisher_api }
      it { expect(packages[3]).not_to be_packed_through_publisher_api }
      it { expect(packages[4]).not_to be_packed_through_publisher_api }
    end

    describe "#to_approve?" do
      it { expect(packages[0]).not_to be_to_approve }
      it { expect(packages[1]).to be_to_approve }
      it { expect(packages[2]).not_to be_to_approve }
      it { expect(packages[3]).not_to be_to_approve }
      it { expect(packages[4]).not_to be_to_approve }
    end

    describe "#approved?" do
      it { expect(packages[0]).not_to be_approved }
      it { expect(packages[1]).not_to be_approved }
      it { expect(packages[2]).to be_approved }
      it { expect(packages[3]).not_to be_approved }
      it { expect(packages[4]).not_to be_approved }
    end

    describe "#rejected?" do
      it { expect(packages[0]).not_to be_rejected }
      it { expect(packages[1]).not_to be_rejected }
      it { expect(packages[2]).not_to be_rejected }
      it { expect(packages[3]).to be_rejected }
      it { expect(packages[4]).to be_rejected }
    end
  end
end
