# frozen_string_literal: true

require "rails_helper"

RSpec.describe Report do
  # Associations
  # ----------------------------------------------------------------------------
  describe "associations" do
    it { is_expected.to belong_to(:collectivity).required }
    it { is_expected.to belong_to(:publisher).optional }
    it { is_expected.to belong_to(:package).required }
    it { is_expected.to belong_to(:workshop).optional }
    it { is_expected.to belong_to(:commune).optional }

    it { is_expected.to have_many(:siblings) }

    it { is_expected.to have_many(:potential_office_communes) }
    it { is_expected.to have_many(:potential_offices) }
    it { is_expected.to have_many(:offices) }
  end

  # Attachments
  # ----------------------------------------------------------------------------
  describe "attachments" do
    it { is_expected.to have_many_attached(:images) }
    it { is_expected.to have_many_attached(:documents) }
  end

  # Validations
  # ----------------------------------------------------------------------------
  describe "validations" do
    it { is_expected.to validate_presence_of(:reference) }
    it { is_expected.to validate_presence_of(:form_type) }

    it { is_expected.to validate_inclusion_of(:form_type).in_array(Report::FORM_TYPES) }
    it { is_expected.to validate_inclusion_of(:priority).in_array(%w[low medium high]) }

    it "validates uniqueness of :reference" do
      create(:report)
      is_expected.to validate_uniqueness_of(:reference).ignoring_case_sensitivity
    end

    it "validates uniqueness of :reference against discarded records" do
      create(:report, :discarded)
      is_expected.to validate_uniqueness_of(:reference).ignoring_case_sensitivity
    end

    it "validates that :anomalies must be an array" do
      aggregate_failures do
        is_expected.to     allow_value([]).for(:anomalies)
        is_expected.not_to allow_value(nil).for(:anomalies)

        # After setting :anomalies to aything but nil or an Array, ActiveRecord will convert it to an empty array.
        # So we cannot test invalid string with Shoulda matcher:
        #
        #   is_expected.not_to allow_value("foo").for(:anomalies)
      end
    end

    def random_combinaison(values)
      array = values.map { |v| [v] }
      array += Array.new(values.size) { values.sample(2) }
      array.uniq
    end

    it "validates that :anomalies accept only combinaison of valid values when reporting an evaluation_local_habitation" do
      report = build(:report, :evaluation_local_habitation)

      allowed_arrays = random_combinaison(%w[consistance affectation exoneration correctif adresse])
      invalid_arrays = random_combinaison(%w[occupation omission_batie])

      aggregate_failures do
        expect(report).to     allow_values(*allowed_arrays).for(:anomalies)
        expect(report).not_to allow_values(*invalid_arrays).for(:anomalies)
      end
    end

    it "validates that :anomalies accept only combinaison of valid values when reporting an evaluation_local_professionnel" do
      report = build(:report, :evaluation_local_professionnel)

      allowed_arrays = random_combinaison(%w[consistance affectation exoneration adresse])
      invalid_arrays = random_combinaison(%w[correctif omission_batie])

      aggregate_failures do
        expect(report).to     allow_values(*allowed_arrays).for(:anomalies)
        expect(report).not_to allow_values(*invalid_arrays).for(:anomalies)
      end
    end

    it "validates that :anomalies accept only combinaison of valid values when reporting a creation form" do
      report = build(:report, :creation_local_habitation)

      allowed_arrays = random_combinaison(%w[omission_batie achevement_travaux])
      invalid_arrays = random_combinaison(%w[consistance adresse])

      aggregate_failures do
        expect(report).to     allow_values(*allowed_arrays).for(:anomalies)
        expect(report).not_to allow_values(*invalid_arrays).for(:anomalies)
      end
    end

    it "validates that :anomalies accept only combinaison of valid values when reporting an occupation form" do
      report = build(:report, :occupation_local_habitation)

      allowed_arrays = random_combinaison(%w[occupation adresse])
      invalid_arrays = random_combinaison(%w[consistance affectation])

      aggregate_failures do
        expect(report).to     allow_values(*allowed_arrays).for(:anomalies)
        expect(report).not_to allow_values(*invalid_arrays).for(:anomalies)
      end
    end

    pending "Add missing tests for other validations"
  end

  # Callbacks
  # ----------------------------------------------------------------------------
  describe "callbacks" do
    describe "#generate_sibling_id" do
      it "generates a sibling_id when code INSEE and invariant are provided" do
        report = create(:report, code_insee: "64102", situation_invariant: "1021234567")
        expect(report).to have_attributes(sibling_id: "641021021234567")
      end

      it "lets sibling_id null when code INSEE is missing" do
        report = create(:report, code_insee: nil, situation_invariant: "1021234567")
        expect(report).to have_attributes(sibling_id: nil)
      end

      it "lets sibling_id null when invariant is missing" do
        report = create(:report, code_insee: "64102")
        expect(report).to have_attributes(sibling_id: nil)
      end

      it "resets sibling_id when one of the attribute is removed" do
        report = create(:report, code_insee: "64102", situation_invariant: "1021234567")
        expect {
          report.update(situation_invariant: nil)
        }.to change(report, :sibling_id).to(nil)
      end
    end
  end

  # Scopes
  # ----------------------------------------------------------------------------
  describe "scopes" do
    describe ".sandbox" do
      it "scopes reports tagged as sandbox by publishers" do
        expect {
          described_class.sandbox.load
        }.to perform_sql_query(<<~SQL)
          SELECT     "reports".*
          FROM       "reports"
          INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
          WHERE      "packages"."sandbox" = TRUE
        SQL
      end
    end

    describe ".out_of_sandbox" do
      it "scopes reports by excluding those tagged as sandbox by publishers" do
        expect {
          described_class.out_of_sandbox.load
        }.to perform_sql_query(<<~SQL)
          SELECT     "reports".*
          FROM       "reports"
          INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
          WHERE      "packages"."sandbox" = FALSE
        SQL
      end
    end

    describe ".transmitted" do
      it "scopes reports from transmitted packages" do
        expect {
          described_class.transmitted.load
        }.to perform_sql_query(<<~SQL)
          SELECT     "reports".*
          FROM       "reports"
          INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
          WHERE      "packages"."transmitted_at" IS NOT NULL
        SQL
      end
    end

    describe ".all_kept" do
      it "scopes on kept reports in kept packages" do
        expect {
          described_class.all_kept.load
        }.to perform_sql_query(<<~SQL)
          SELECT     "reports".*
          FROM       "reports"
          INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
          WHERE      "packages"."discarded_at" IS NULL
            AND      "reports"."discarded_at" IS NULL
        SQL
      end
    end

    describe ".published" do
      it "scopes on transmitted reports, not discarded and not tagged as sandbox" do
        expect {
          described_class.published.load
        }.to perform_sql_query(<<~SQL)
          SELECT     "reports".*
          FROM       "reports"
          INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
          WHERE      "packages"."transmitted_at" IS NOT NULL
            AND      "packages"."discarded_at" IS NULL
            AND      "reports"."discarded_at" IS NULL
            AND      "packages"."sandbox" = FALSE
        SQL
      end
    end

    describe ".approved_packages" do
      it "scopes on transmitted reports with package approved by DDFIP" do
        expect {
          described_class.approved_packages.load
        }.to perform_sql_query(<<~SQL)
          SELECT     "reports".*
          FROM       "reports"
          INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
          WHERE      "packages"."transmitted_at" IS NOT NULL
            AND      "packages"."approved_at" IS NOT NULL
            AND      "packages"."rejected_at" IS NULL
        SQL
      end
    end

    describe ".rejected_packages" do
      it "scopes on transmitted reports with package rejected by DDFIP" do
        expect {
          described_class.rejected_packages.load
        }.to perform_sql_query(<<~SQL)
          SELECT     "reports".*
          FROM       "reports"
          INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
          WHERE      "packages"."transmitted_at" IS NOT NULL
            AND      "packages"."rejected_at" IS NOT NULL
        SQL
      end
    end

    describe ".unrejected_packages" do
      it "scopes on transmitted reports with package not yet rejected by DDFIP" do
        expect {
          described_class.unrejected_packages.load
        }.to perform_sql_query(<<~SQL)
          SELECT     "reports".*
          FROM       "reports"
          INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
          WHERE      "packages"."transmitted_at" IS NOT NULL
            AND      "packages"."rejected_at" IS NULL
        SQL
      end
    end

    describe ".pending" do
      it "scopes on published reports waiting for decision" do
        expect {
          described_class.pending.load
        }.to perform_sql_query(<<~SQL)
          SELECT     "reports".*
          FROM       "reports"
          INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
          WHERE      "packages"."transmitted_at" IS NOT NULL
            AND      "packages"."discarded_at" IS NULL
            AND      "reports"."discarded_at" IS NULL
            AND      "packages"."sandbox" = FALSE
            AND      "reports"."approved_at" IS NULL
            AND      "reports"."rejected_at" IS NULL
            AND      "reports"."debated_at" IS NULL
        SQL
      end
    end

    describe ".approved" do
      it "scopes on approved reports" do
        expect {
          described_class.approved.load
        }.to perform_sql_query(<<~SQL)
          SELECT     "reports".*
          FROM       "reports"
          INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
          WHERE      "packages"."transmitted_at" IS NOT NULL
            AND      "packages"."discarded_at" IS NULL
            AND      "reports"."discarded_at" IS NULL
            AND      "packages"."sandbox" = FALSE
            AND      "reports"."approved_at" IS NOT NULL
        SQL
      end
    end

    describe ".rejected" do
      it "scopes on rejected reports" do
        expect {
          described_class.rejected.load
        }.to perform_sql_query(<<~SQL)
          SELECT     "reports".*
          FROM       "reports"
          INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
          WHERE      "packages"."transmitted_at" IS NOT NULL
            AND      "packages"."discarded_at" IS NULL
            AND      "reports"."discarded_at" IS NULL
            AND      "packages"."sandbox" = FALSE
            AND      "reports"."rejected_at" IS NOT NULL
        SQL
      end
    end

    describe ".debated" do
      it "scopes on debated reports" do
        expect {
          described_class.debated.load
        }.to perform_sql_query(<<~SQL)
          SELECT     "reports".*
          FROM       "reports"
          INNER JOIN "packages" ON "packages"."id" = "reports"."package_id"
          WHERE      "packages"."transmitted_at" IS NOT NULL
            AND      "packages"."discarded_at" IS NULL
            AND      "reports"."discarded_at" IS NULL
            AND      "packages"."sandbox" = FALSE
            AND      "reports"."debated_at" IS NOT NULL
        SQL
      end
    end

    describe ".packed_through_publisher_api" do
      it "scopes on reports sent through API" do
        expect {
          described_class.packed_through_publisher_api.load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."publisher_id" IS NOT NULL
        SQL
      end
    end

    describe ".packed_through_web_ui" do
      it "scopes on reports created through Web UI" do
        expect {
          described_class.packed_through_web_ui.load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."publisher_id" IS NULL
        SQL
      end
    end

    describe ".sent_by_collectivity" do
      it "scopes on reports sent by one single collectivity" do
        collectivity = create(:collectivity)

        expect {
          described_class.sent_by_collectivity(collectivity).load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."collectivity_id" = '#{collectivity.id}'
        SQL
      end

      it "scopes on reports sent by many collectivities" do
        expect {
          described_class.sent_by_collectivity(Collectivity.where(name: "A")).load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."collectivity_id" IN (
            SELECT "collectivities"."id"
            FROM   "collectivities"
            WHERE  "collectivities"."name" = 'A'
          )
        SQL
      end
    end

    describe ".sent_by_publisher" do
      it "scopes on reports sent by one single publisher" do
        publisher = create(:publisher)

        expect {
          described_class.sent_by_publisher(publisher).load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."publisher_id" = '#{publisher.id}'
        SQL
      end

      it "scopes on reports sent by many publishers" do
        expect {
          described_class.sent_by_publisher(Publisher.where(name: "A")).load
        }.to perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  "reports"."publisher_id" IN (
            SELECT "publishers"."id"
            FROM   "publishers"
            WHERE  "publishers"."name" = 'A'
          )
        SQL
      end
    end

    describe ".covered_by_ddfip" do
      it "scopes reports covered by one single DDFIP" do
        departement = create(:departement, code_departement: "64")
        ddfip       = create(:ddfip, departement: departement)

        expect {
          described_class.covered_by_ddfip(ddfip).load
        }.to perform_sql_query(<<~SQL)
          SELECT     "reports".*
          FROM       "reports"
          INNER JOIN "communes" ON "communes"."code_insee" = "reports"."code_insee"
          WHERE      "communes"."code_departement" = '64'
        SQL
      end

      it "scopes reports covered by many DDFIPs" do
        expect {
          described_class.covered_by_ddfip(DDFIP.where(name: "A")).load
        }.to perform_sql_query(<<~SQL)
          SELECT     "reports".*
          FROM       "reports"
          INNER JOIN "communes" ON "communes"."code_insee" = "reports"."code_insee"
          WHERE      "communes"."code_departement" IN (
            SELECT "ddfips"."code_departement"
            FROM   "ddfips"
            WHERE  "ddfips"."name" = 'A'
          )
        SQL
      end
    end

    describe ".covered_by_office" do
      it "scopes reports covered by one single office" do
        office = create(:office, :evaluation_local_habitation)

        expect {
          described_class.covered_by_office(office).load
        }.to perform_sql_query(<<~SQL)
          SELECT     DISTINCT "reports".*
          FROM       "reports"
          INNER JOIN "office_communes" ON "office_communes"."code_insee" = "reports"."code_insee"
          WHERE      "office_communes"."office_id" = '#{office.id}'
            AND      "reports"."form_type" = 'evaluation_local_habitation'
        SQL
      end

      it "scopes reports covered by one single office with multiple competences" do
        office = create(:office, competences: %w[evaluation_local_habitation evaluation_local_professionnel])

        expect {
          described_class.covered_by_office(office).load
        }.to perform_sql_query(<<~SQL)
          SELECT     DISTINCT "reports".*
          FROM       "reports"
          INNER JOIN "office_communes" ON "office_communes"."code_insee" = "reports"."code_insee"
          WHERE      "office_communes"."office_id" = '#{office.id}'
            AND      "reports"."form_type" IN ('evaluation_local_habitation', 'evaluation_local_professionnel')
        SQL
      end

      it "scopes reports covered by many offices" do
        expect {
          described_class.covered_by_office(Office.where(name: "A")).load
        }.to perform_sql_query(<<~SQL)
          SELECT     DISTINCT "reports".*
          FROM       "reports"
          INNER JOIN "office_communes" ON "office_communes"."code_insee" = "reports"."code_insee"
          INNER JOIN "offices" ON "offices"."id" = "office_communes"."office_id"
          WHERE      "offices"."name" = 'A'
            AND      ("reports"."form_type" = ANY ("offices"."competences"))
        SQL
      end
    end
  end

  # Predicates
  # ----------------------------------------------------------------------------
  describe "predicates" do
    # Use only one collectivity to reduce the number of queries and records to create
    let_it_be(:publisher)    { build(:publisher) }
    let_it_be(:collectivity) { build(:collectivity, publisher: publisher) }
    let_it_be(:packages) do
      [
        build(:package, collectivity: collectivity),
        build(:package, :transmitted, collectivity: collectivity),
        build(:package, :transmitted, collectivity: collectivity, publisher: publisher, sandbox: true),
        build(:package, :rejected,            collectivity: collectivity),
        build(:package, :approved, :rejected, collectivity: collectivity),
        build(:package, :approved,            collectivity: collectivity)
      ]
    end

    let_it_be(:reports) do
      [
        build(:report, package: packages[0]),             # 0
        build(:report, package: packages[1]),             # 1
        build(:report, package: packages[2]),             # 2
        build(:report, package: packages[3]),             # 3
        build(:report, package: packages[4]),             # 4
        build(:report, package: packages[5]),             # 5
        build(:report, :discarded, package: packages[5]), # 6
        build(:report, :approved,  package: packages[5]), # 7
        build(:report, :rejected,  package: packages[5]), # 8
        build(:report, :debated,   package: packages[5])  # 9
      ]
    end

    describe "#transmitted?" do
      it { expect(reports[0]).not_to be_transmitted }
      it { expect(reports[1..]).to all(be_transmitted) }
    end

    describe "#published?" do
      it { expect(reports[0]).not_to be_published }
      it { expect(reports[1]).to     be_published }
      it { expect(reports[2]).not_to be_published }
      it { expect(reports[3]).to     be_published }
      it { expect(reports[4]).to     be_published }
      it { expect(reports[5]).to     be_published }
      it { expect(reports[6]).not_to be_published }
      it { expect(reports[7]).to     be_published }
      it { expect(reports[8]).to     be_published }
      it { expect(reports[9]).to     be_published }
    end

    describe "#pending?" do
      it { expect(reports[5]).to     be_pending }
      it { expect(reports[6]).not_to be_pending }
      it { expect(reports[7]).not_to be_pending }
      it { expect(reports[8]).not_to be_pending }
      it { expect(reports[9]).not_to be_pending }
    end

    describe "#approved?" do
      it { expect(reports[5]).not_to be_approved }
      it { expect(reports[6]).not_to be_approved }
      it { expect(reports[7]).to     be_approved }
      it { expect(reports[8]).not_to be_approved }
      it { expect(reports[9]).not_to be_approved }
    end

    describe "#rejected?" do
      it { expect(reports[5]).not_to be_rejected }
      it { expect(reports[6]).not_to be_rejected }
      it { expect(reports[7]).not_to be_rejected }
      it { expect(reports[8]).to     be_rejected }
      it { expect(reports[9]).not_to be_rejected }
    end

    describe "#debated?" do
      it { expect(reports[5]).not_to be_debated }
      it { expect(reports[6]).not_to be_debated }
      it { expect(reports[7]).not_to be_debated }
      it { expect(reports[8]).not_to be_debated }
      it { expect(reports[9]).to     be_debated }
    end
  end

  # Updates methods
  # ----------------------------------------------------------------------------
  describe "update methods" do
    describe "#anomalies=" do
      it "assigns the arrray passed as argument" do
        expect(
          Report.new(anomalies: %w[consistance adresse])
        ).to have_attributes(anomalies: %w[consistance adresse])
      end

      it "removes blank values from array" do
        expect(
          Report.new(anomalies: ["", "consistance", "adresse"])
        ).to have_attributes(anomalies: %w[consistance adresse])
      end

      it "maintains default Rails behavior when assigning non-array values" do
        expect(
          Report.new(anomalies: "consistance adresse")
        ).to have_attributes(anomalies: [])
      end
    end

    describe "#approve!" do
      it "marks the report as approved" do
        report = create(:report, :transmitted)

        aggregate_failures do
          expect {
            expect(report.approve!).to be(true)
            report.reload
          }.to change(report, :approved_at).to(be_present)
        end
      end

      it "resets rejection time when previously rejected" do
        report = create(:report, :rejected)

        aggregate_failures do
          expect {
            expect(report.approve!).to be(true)
            report.reload
          }.to change(report, :rejected_at).to(nil)
            .and change(report, :approved_at).to(be_present)
        end
      end

      it "doesn't update previous approval time when already approved" do
        report = Timecop.freeze(2.minutes.ago) do
          create(:report, :approved)
        end

        aggregate_failures do
          expect {
            expect(report.approve!).to be(true)
            report.reload
          }.not_to change(report, :approved_at)
        end
      end
    end

    describe "#reject!" do
      it "marks the report as rejected" do
        report = create(:report, :transmitted)

        aggregate_failures do
          expect {
            expect(report.reject!).to be(true)
            report.reload
          }.to change(report, :rejected_at).to(be_present)
        end
      end

      it "reset approval time when previously approved" do
        report = create(:report, :approved)

        aggregate_failures do
          expect {
            expect(report.reject!).to be(true)
            report.reload
          }.to change(report, :approved_at).to(nil)
            .and change(report, :rejected_at).to(be_present)
        end
      end

      it "doesn't update previous rejection time when already rejected" do
        report = Timecop.freeze(2.minutes.ago) do
          create(:report, :rejected)
        end

        aggregate_failures do
          expect {
            expect(report.reject!).to be(true)
            report.reload
          }.not_to change(report, :rejected_at)
        end
      end
    end

    describe "#debate!" do
      it "marks the report as debated" do
        report = create(:report, :transmitted)

        aggregate_failures do
          expect {
            expect(report.debate!).to be(true)
            report.reload
          }.to change(report, :debated_at).to(be_present)
        end
      end

      it "doesn't overwrite previous debated time" do
        report = Timecop.freeze(2.minutes.ago) do
          create(:report, :debated)
        end

        aggregate_failures do
          expect {
            expect(report.debate!).to be(true)
            report.reload
          }.not_to change(report, :debated_at)
        end
      end

      it "doesn't update an approved report" do
        report = create(:report, :approved)

        aggregate_failures do
          expect {
            expect(report.debate!).to be(false)
            report.reload
          }.to not_change(report, :debated_at).from(nil)
            .and not_change(report, :approved_at).from(be_present)
        end
      end

      it "doesn't update a rejected report" do
        report = create(:report, :rejected)

        aggregate_failures do
          expect {
            expect(report.debate!).to be(false)
            report.reload
          }.to not_change(report, :debated_at).from(nil)
            .and not_change(report, :rejected_at).from(be_present)
        end
      end
    end
  end

  # Database constraints and triggers
  # ----------------------------------------------------------------------------
  describe "database constraints" do
    let(:report) { create(:report) }

    it "asserts a form_type is allowed by not triggering DB constraints" do
      expect { report.update_columns(form_type: "evaluation_local_habitation") }
        .not_to raise_error
    end

    it "asserts a form_type is not allowed by triggering DB constraints" do
      expect { report.update_columns(form_type: "foo") }
        .to raise_error(ActiveRecord::StatementInvalid).with_message(/PG::InvalidTextRepresentation/)
    end

    it "asserts a priority is allowed by not triggering DB constraints" do
      expect { report.update_columns(priority: "high") }
        .not_to raise_error
    end

    it "asserts a priority is not allowed by triggering DB constraints" do
      expect { report.update_columns(priority: "higher") }
        .to raise_error(ActiveRecord::StatementInvalid).with_message(/PG::InvalidTextRepresentation/)
    end
  end

  describe "database triggers" do
    pending "TODO"
  end
end
