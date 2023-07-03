# frozen_string_literal: true

require "rails_helper"

RSpec.describe Office do
  # Associations
  # ----------------------------------------------------------------------------
  describe "associations" do
    it { is_expected.to belong_to(:ddfip).required }

    it { is_expected.to have_many(:office_communes) }
    it { is_expected.to have_many(:office_users) }

    it { is_expected.to have_many(:users).through(:office_users) }
    it { is_expected.to have_many(:communes).through(:office_communes) }

    it { is_expected.to have_one(:departement).through(:ddfip) }
    it { is_expected.to have_many(:departement_communes).through(:departement) }
  end

  # Validations
  # ----------------------------------------------------------------------------
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }

    it "validates that :competences must be an array" do
      aggregate_failures do
        is_expected.to     allow_value([]).for(:competences)
        is_expected.not_to allow_value(nil).for(:competences)

        # Invalid values are converted to an empty array
        # So we cannot test with string:
        #
        #   is_expected.not_to allow_value(Office::COMPETENCES.sample).for(:competences)
      end
    end

    it "validates that :competences accept only combinaison of valid values" do
      valid_values = Office::COMPETENCES

      allowed_arrays = valid_values.map { |v| [v] }
      allowed_arrays += Array.new(4) { valid_values.sample(2) }

      invalid_arrays = []
      invalid_arrays << [Faker::Lorem.word]
      invalid_arrays << [Faker::Lorem.word, valid_values.sample]

      aggregate_failures do
        is_expected.to     allow_values(*allowed_arrays).for(:competences)
        is_expected.not_to allow_values(*invalid_arrays).for(:competences)
      end
    end

    it "validates uniqueness of :name" do
      create(:office)
      is_expected.to validate_uniqueness_of(:name).ignoring_case_sensitivity.scoped_to(:ddfip_id)
    end

    it "ignores discarded records when validating uniqueness of :name" do
      create(:office, :discarded)
      is_expected.not_to validate_uniqueness_of(:name).ignoring_case_sensitivity.scoped_to(:ddfip_id)
    end

    it "raises an exception when undiscarding a record when its attributes is already used by other records" do
      discarded_office = create(:office, :discarded)
      create(:office, ddfip: discarded_office.ddfip, name: discarded_office.name)

      expect { discarded_office.undiscard }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  # Scopes
  # ----------------------------------------------------------------------------
  describe "scopes" do
    pending "Add more tests about scopes"
  end

  # Other associations
  # ----------------------------------------------------------------------------
  describe "other associations" do
    describe "#on_territory_collectivities" do
      pending "Add more tests about such association"
    end
  end

  # Updates methods
  # ----------------------------------------------------------------------------
  describe "update methods" do
    describe "#competences=" do
      it "assigns the arrray passed as argument" do
        expect(
          Office.new(competences: %w[evaluation_local_habitation])
        ).to have_attributes(competences: %w[evaluation_local_habitation])
      end

      it "removes blank values from array" do
        expect(
          Office.new(competences: ["", "evaluation_local_habitation"])
        ).to have_attributes(competences: %w[evaluation_local_habitation])
      end

      it "maintains default Rails behavior when assigning non-array values" do
        expect(
          Office.new(competences: "evaluation_local_habitation")
        ).to have_attributes(competences: [])
      end
    end

    describe ".reset_all_counters" do
      subject(:reset_all_counters) { described_class.reset_all_counters }

      let!(:ddfip)   { create(:ddfip) }
      let!(:offices) { create_list(:office, 2, ddfip: ddfip) }

      it { expect { reset_all_counters }.to ret(2) }
      it { expect { reset_all_counters }.to perform_sql_query("SELECT reset_all_offices_counters()") }

      describe "on users_count" do
        before do
          users = create_list(:user, 6)

          offices[0].users = users.shuffle.take(4)
          offices[1].users = users.shuffle.take(2)

          Office.update_all(users_count: 0)
        end

        it { expect { reset_all_counters }.to change { offices[0].reload.users_count }.from(0).to(4) }
        it { expect { reset_all_counters }.to change { offices[1].reload.users_count }.from(0).to(2) }
      end

      describe "on communes_count" do
        before do
          communes = create_list(:commune, 6, departement: ddfip.departement)

          offices[0].communes = communes.shuffle.take(4)
          offices[1].communes = communes.shuffle.take(2)

          Office.update_all(communes_count: 0)
        end

        it { expect { reset_all_counters }.to change { offices[0].reload.communes_count }.from(0).to(4) }
        it { expect { reset_all_counters }.to change { offices[1].reload.communes_count }.from(0).to(2) }
      end

      describe "on reports_count" do
        let!(:offices) { create_list(:office, 2, :with_communes, ddfip: ddfip) }

        before do
          create_list(:report, 4, :reported_for_office, :package_approved_by_ddfip, ddfip: ddfip, office: offices[0])
          create_list(:report, 2, :reported_for_office, :package_approved_by_ddfip, ddfip: ddfip, office: offices[1])

          Office.update_all(reports_count: 0)
        end

        it { expect { reset_all_counters }.to change { offices[0].reload.reports_count }.from(0).to(4) }
        it { expect { reset_all_counters }.to change { offices[1].reload.reports_count }.from(0).to(2) }
      end

      describe "on reports_approved_count" do
        let!(:offices) { create_list(:office, 2, :with_communes, ddfip: ddfip) }

        before do
          create_list(:report, 4, :reported_for_office, :package_approved_by_ddfip, :approved, ddfip: ddfip, office: offices[0])
          create_list(:report, 2, :reported_for_office, :package_approved_by_ddfip, :approved, ddfip: ddfip, office: offices[1])
          create_list(:report, 1, :reported_for_office, :package_approved_by_ddfip, ddfip: ddfip, office: offices[0])
          create_list(:report, 1, :reported_for_office, :package_approved_by_ddfip, ddfip: ddfip, office: offices[1])

          Office.update_all(reports_approved_count: 0)
        end

        it { expect { reset_all_counters }.to change { offices[0].reload.reports_approved_count }.from(0).to(4) }
        it { expect { reset_all_counters }.to change { offices[1].reload.reports_approved_count }.from(0).to(2) }
      end

      describe "on reports_rejected_count" do
        let!(:offices) { create_list(:office, 2, :with_communes, ddfip: ddfip) }

        before do
          create_list(:report, 4, :reported_for_office, :package_approved_by_ddfip, :rejected, ddfip: ddfip, office: offices[0])
          create_list(:report, 2, :reported_for_office, :package_approved_by_ddfip, :rejected, ddfip: ddfip, office: offices[1])
          create_list(:report, 1, :reported_for_office, :package_approved_by_ddfip, ddfip: ddfip, office: offices[0])
          create_list(:report, 1, :reported_for_office, :package_approved_by_ddfip, ddfip: ddfip, office: offices[1])

          Office.update_all(reports_rejected_count: 0)
        end

        it { expect { reset_all_counters }.to change { offices[0].reload.reports_rejected_count }.from(0).to(4) }
        it { expect { reset_all_counters }.to change { offices[1].reload.reports_rejected_count }.from(0).to(2) }
      end

      describe "on reports_debated_count" do
        let!(:offices) { create_list(:office, 2, :with_communes, ddfip: ddfip) }

        before do
          create_list(:report, 4, :reported_for_office, :package_approved_by_ddfip, :debated, ddfip: ddfip, office: offices[0])
          create_list(:report, 2, :reported_for_office, :package_approved_by_ddfip, :debated, ddfip: ddfip, office: offices[1])
          create_list(:report, 1, :reported_for_office, :package_approved_by_ddfip, ddfip: ddfip, office: offices[0])
          create_list(:report, 1, :reported_for_office, :package_approved_by_ddfip, ddfip: ddfip, office: offices[1])

          Office.update_all(reports_debated_count: 0)
        end

        it { expect { reset_all_counters }.to change { offices[0].reload.reports_debated_count }.from(0).to(4) }
        it { expect { reset_all_counters }.to change { offices[1].reload.reports_debated_count }.from(0).to(2) }
      end
    end
  end

  # Database constraints and triggers
  # ----------------------------------------------------------------------------
  describe "database constraints" do
    it "asserts the uniqueness of name" do
      existing_office = create(:office)
      another_office  = build(:office, ddfip_id: existing_office.ddfip_id, name: existing_office.name)

      expect { another_office.save(validate: false) }
        .to raise_error(ActiveRecord::RecordNotUnique).with_message(/PG::UniqueViolation/)
    end

    it "asserts a competence is allowed by not triggering DB constraints" do
      office = build(:office, competences: %w[evaluation_local_habitation])

      expect { office.save(validate: false) }
        .not_to raise_error
    end

    it "asserts a competence is not allowed by triggering DB constraints" do
      office = build(:office, competences: %w[foo])

      expect { office.save(validate: false) }
        .to raise_error(ActiveRecord::StatementInvalid).with_message(/PG::InvalidTextRepresentation/)
    end
  end

  describe "database triggers" do
    describe "about users counter cache" do
      let!(:ddfip)   { create(:ddfip) }
      let!(:offices) { create_list(:office, 2, ddfip: ddfip) }
      let!(:user)    { create(:user) }

      describe "#users_count" do
        it "changes when users is assigned to the office" do
          expect { offices[0].users << user }
            .to      change { offices[0].reload.users_count }.from(0).to(1)
            .and not_change { offices[1].reload.users_count }.from(0)
        end

        it "changes when users is removed from the office" do
          offices[0].users << user

          expect { offices[0].users.delete(user) }
            .to      change { offices[0].reload.users_count }.from(1).to(0)
            .and not_change { offices[1].reload.users_count }.from(0)
        end

        it "changes when users is destroyed" do
          offices[0].users << user

          expect { user.destroy }
            .to      change { offices[0].reload.users_count }.from(1).to(0)
            .and not_change { offices[1].reload.users_count }.from(0)
        end

        it "changes when discarding" do
          offices[0].users << user

          expect { user.discard }
            .to      change { offices[0].reload.users_count }.from(1).to(0)
            .and not_change { offices[1].reload.users_count }.from(0)
        end

        it "changes when undiscarding" do
          offices[0].users << user
          user.discard

          expect { user.undiscard }
            .to      change { offices[0].reload.users_count }.from(0).to(1)
            .and not_change { offices[1].reload.users_count }.from(0)
        end
      end
    end

    describe "about communes counter cache" do
      let!(:ddfip)   { create(:ddfip) }
      let!(:offices) { create_list(:office, 2, ddfip: ddfip) }
      let!(:commune) { create(:commune, code_insee: "64102") }

      describe "#communes_count" do
        it "changes when communes is assigned to the office" do
          expect { offices[0].communes << commune }
            .to      change { offices[0].reload.communes_count }.from(0).to(1)
            .and not_change { offices[1].reload.communes_count }.from(0)
        end

        it "changes when an existing code_insee is assigned to the office" do
          expect { offices[0].office_communes.create(code_insee: "64102") }
            .to      change { offices[0].reload.communes_count }.from(0).to(1)
            .and not_change { offices[1].reload.communes_count }.from(0)
        end

        it "doesn't change when an unknown code_insee is assigned to the office" do
          expect { offices[0].office_communes.create(code_insee: "64024") }
            .to  not_change { offices[0].reload.communes_count }.from(0)
            .and not_change { offices[1].reload.communes_count }.from(0)
        end

        it "changes when commune is removed from the office" do
          offices[0].communes << commune

          expect { offices[0].communes.delete(commune) }
            .to      change { offices[0].reload.communes_count }.from(1).to(0)
            .and not_change { offices[1].reload.communes_count }.from(0)
        end

        it "changes when commune is destroyed" do
          offices[0].communes << commune

          expect { commune.destroy }
            .to      change { offices[0].reload.communes_count }.from(1).to(0)
            .and not_change { offices[1].reload.communes_count }.from(0)
        end

        it "changes when commune updates its code_insee" do
          offices[0].communes << commune

          expect { commune.update(code_insee: "64024") }
            .to      change { offices[0].reload.communes_count }.from(1).to(0)
            .and not_change { offices[1].reload.communes_count }.from(0)
        end
      end
    end

    describe "about reports counter caches" do
      let!(:ddfip) { create(:ddfip) }
      let!(:offices) do
        # Create tree offices:
        # - one with the right competence and territory
        # - one with the right competence but wrong territory
        # - one with the right territory but wrong competence
        #
        offices = []
        offices << create(:office, :evaluation_local_habitation, :with_communes, ddfip: ddfip)
        offices << create(:office, :evaluation_local_habitation, :with_communes, ddfip: ddfip)
        offices << create(:office, :evaluation_local_professionnel, ddfip: ddfip, communes: offices[0].communes)
        offices
      end

      describe "#reports_count" do
        let(:report) { create(:report, :reported_for_office, office: offices[0]) }

        it "doesn't change on report creation" do
          expect { report }
            .to  not_change { offices[0].reload.reports_count }.from(0)
            .and not_change { offices[1].reload.reports_count }.from(0)
            .and not_change { offices[2].reload.reports_count }.from(0)
        end

        it "doesn't change when package is transmitted" do
          report

          expect { report.package.transmit! }
            .to  not_change { offices[0].reload.reports_count }.from(0)
            .and not_change { offices[1].reload.reports_count }.from(0)
            .and not_change { offices[2].reload.reports_count }.from(0)
        end

        it "changes when transmitted package is approved" do
          report.package.transmit!

          expect { report.package.approve! }
            .to      change { offices[0].reload.reports_count }.from(0).to(1)
            .and not_change { offices[1].reload.reports_count }.from(0)
            .and not_change { offices[2].reload.reports_count }.from(0)
        end

        it "doesn't changes when package in sandbox is transmitted" do
          report.package.update(sandbox: true)

          expect { report.package.transmit! }
            .to  not_change { offices[0].reload.reports_count }.from(0)
            .and not_change { offices[1].reload.reports_count }.from(0)
            .and not_change { offices[2].reload.reports_count }.from(0)
        end

        it "doesn't changes when transmitted package in sandbox is approved" do
          report.package.update(sandbox: true) and report.package.transmit!

          expect { report.package.approve! }
            .to  not_change { offices[0].reload.reports_count }.from(0)
            .and not_change { offices[1].reload.reports_count }.from(0)
            .and not_change { offices[2].reload.reports_count }.from(0)
        end

        it "changes when transmitted report in approved package is discarded" do
          report.package.touch(:transmitted_at) and report.package.approve!

          expect { report.discard }
            .to      change { offices[0].reload.reports_count }.from(1).to(0)
            .and not_change { offices[1].reload.reports_count }.from(0)
            .and not_change { offices[2].reload.reports_count }.from(0)
        end

        it "changes when transmitted report in approved package is undiscarded" do
          report.discard and report.package.transmit! and report.package.approve!

          expect { report.undiscard }
            .to      change { offices[0].reload.reports_count }.from(0).to(1)
            .and not_change { offices[1].reload.reports_count }.from(0)
            .and not_change { offices[2].reload.reports_count }.from(0)
        end

        it "changes when transmitted report in approved package is deleted" do
          report.package.transmit! and report.package.approve!

          expect { report.destroy }
            .to      change { offices[0].reload.reports_count }.from(1).to(0)
            .and not_change { offices[1].reload.reports_count }.from(0)
            .and not_change { offices[2].reload.reports_count }.from(0)
        end

        it "doesn't change when transmitted package is discarded" do
          report.package.transmit!

          expect { report.package.discard }
            .to  not_change { offices[0].reload.reports_count }.from(0)
            .and not_change { offices[1].reload.reports_count }.from(0)
            .and not_change { offices[2].reload.reports_count }.from(0)
        end

        it "changes when transmitted and approved package is discarded" do
          report.package.transmit! and report.package.approve!

          expect { report.package.discard }
            .to      change { offices[0].reload.reports_count }.from(1).to(0)
            .and not_change { offices[1].reload.reports_count }.from(0)
            .and not_change { offices[2].reload.reports_count }.from(0)
        end

        it "doesn't change when transmitted package is undiscarded" do
          report.package.touch(:transmitted_at, :discarded_at)

          expect { report.package.undiscard }
            .to  not_change { offices[0].reload.reports_count }.from(0)
            .and not_change { offices[1].reload.reports_count }.from(0)
            .and not_change { offices[2].reload.reports_count }.from(0)
        end

        it "changes when transmitted and approved package is undiscarded" do
          report.package.touch(:transmitted_at, :discarded_at, :approved_at)

          expect { report.package.undiscard }
            .to      change { offices[0].reload.reports_count }.from(0).to(1)
            .and not_change { offices[1].reload.reports_count }.from(0)
            .and not_change { offices[2].reload.reports_count }.from(0)
        end

        it "doesn't change when transmitted package is deleted" do
          report.package.transmit!

          expect { report.package.delete }
            .to  not_change { offices[0].reload.reports_count }.from(0)
            .and not_change { offices[1].reload.reports_count }.from(0)
            .and not_change { offices[2].reload.reports_count }.from(0)
        end

        it "changes when transmitted and approved package is deleted" do
          report.package.transmit! and report.package.approve!

          expect { report.package.delete }
            .to      change { offices[0].reload.reports_count }.from(1).to(0)
            .and not_change { offices[1].reload.reports_count }.from(0)
            .and not_change { offices[2].reload.reports_count }.from(0)
        end
      end

      describe "#reports_approved_count" do
        let(:report) { create(:report, :reported_for_office, office: offices[0]) }

        it "doesn't change on report creation" do
          expect { report }
            .to  not_change { offices[0].reload.reports_approved_count }.from(0)
            .and not_change { offices[1].reload.reports_approved_count }.from(0)
            .and not_change { offices[2].reload.reports_approved_count }.from(0)
        end

        it "doesn't change when transmitted report is approved" do
          report.package.touch(:transmitted_at)

          expect { report.approve! }
            .to  not_change { offices[0].reload.reports_approved_count }.from(0)
            .and not_change { offices[1].reload.reports_approved_count }.from(0)
            .and not_change { offices[2].reload.reports_approved_count }.from(0)
        end

        it "changes when transmitted report in approved package is approved" do
          report.package.touch(:transmitted_at, :approved_at)

          expect { report.approve! }
            .to      change { offices[0].reload.reports_approved_count }.from(0).to(1)
            .and not_change { offices[1].reload.reports_approved_count }.from(0)
            .and not_change { offices[2].reload.reports_approved_count }.from(0)
        end

        it "doesn't change when approved and transmitted report is discarded" do
          report.approve! and report.package.touch(:transmitted_at)

          expect { report.discard }
            .to  not_change { offices[0].reload.reports_approved_count }.from(0)
            .and not_change { offices[1].reload.reports_approved_count }.from(0)
            .and not_change { offices[2].reload.reports_approved_count }.from(0)
        end

        it "changes when approved and transmitted report in approved package is discarded" do
          report.approve! and report.package.touch(:transmitted_at, :approved_at)

          expect { report.discard }
            .to      change { offices[0].reload.reports_approved_count }.from(1).to(0)
            .and not_change { offices[1].reload.reports_approved_count }.from(0)
            .and not_change { offices[2].reload.reports_approved_count }.from(0)
        end

        it "doesn't change when approved and transmitted report is undiscarded" do
          report.touch(:approved_at, :discarded_at) and report.package.touch(:transmitted_at)

          expect { report.undiscard }
            .to  not_change { offices[0].reload.reports_approved_count }.from(0)
            .and not_change { offices[1].reload.reports_approved_count }.from(0)
            .and not_change { offices[2].reload.reports_approved_count }.from(0)
        end

        it "changes when approved and transmitted report in approved package is undiscarded" do
          report.touch(:approved_at, :discarded_at) and report.package.touch(:transmitted_at, :approved_at)

          expect { report.undiscard }
            .to      change { offices[0].reload.reports_approved_count }.from(0).to(1)
            .and not_change { offices[1].reload.reports_approved_count }.from(0)
            .and not_change { offices[2].reload.reports_approved_count }.from(0)
        end

        it "doesn't change when approved and transmitted report is deleted" do
          report.approve! and report.package.touch(:transmitted_at)

          expect { report.delete }
            .to  not_change { offices[0].reload.reports_approved_count }.from(0)
            .and not_change { offices[1].reload.reports_approved_count }.from(0)
            .and not_change { offices[2].reload.reports_approved_count }.from(0)
        end

        it "changes when approved and transmitted report in approved package is deleted" do
          report.approve! and report.package.touch(:transmitted_at, :approved_at)

          expect { report.delete }
            .to      change { offices[0].reload.reports_approved_count }.from(1).to(0)
            .and not_change { offices[1].reload.reports_approved_count }.from(0)
            .and not_change { offices[2].reload.reports_approved_count }.from(0)
        end
      end

      describe "#reports_rejected_count" do
        let(:report) { create(:report, :reported_for_office, office: offices[0]) }

        it "doesn't change on report creation" do
          expect { report }
            .to  not_change { offices[0].reload.reports_rejected_count }.from(0)
            .and not_change { offices[1].reload.reports_rejected_count }.from(0)
            .and not_change { offices[2].reload.reports_rejected_count }.from(0)
        end

        it "doesn't change when transmitted report is rejected" do
          report.package.touch(:transmitted_at)

          expect { report.reject! }
            .to  not_change { offices[0].reload.reports_rejected_count }.from(0)
            .and not_change { offices[1].reload.reports_rejected_count }.from(0)
            .and not_change { offices[2].reload.reports_rejected_count }.from(0)
        end

        it "changes when transmitted report in approved package is rejected" do
          report.package.touch(:transmitted_at, :approved_at)

          expect { report.reject! }
            .to      change { offices[0].reload.reports_rejected_count }.from(0).to(1)
            .and not_change { offices[1].reload.reports_rejected_count }.from(0)
            .and not_change { offices[2].reload.reports_rejected_count }.from(0)
        end

        it "doesn't change when rejected and transmitted report is discarded" do
          report.reject! and report.package.touch(:transmitted_at)

          expect { report.discard }
            .to  not_change { offices[0].reload.reports_rejected_count }.from(0)
            .and not_change { offices[1].reload.reports_rejected_count }.from(0)
            .and not_change { offices[2].reload.reports_rejected_count }.from(0)
        end

        it "changes when rejected and transmitted report in approved package is discarded" do
          report.reject! and report.package.touch(:transmitted_at, :approved_at)

          expect { report.discard }
            .to      change { offices[0].reload.reports_rejected_count }.from(1).to(0)
            .and not_change { offices[1].reload.reports_rejected_count }.from(0)
            .and not_change { offices[2].reload.reports_rejected_count }.from(0)
        end

        it "doesn't change when rejected and transmitted report is undiscarded" do
          report.touch(:rejected_at, :discarded_at) and report.package.touch(:transmitted_at)

          expect { report.undiscard }
            .to  not_change { offices[0].reload.reports_rejected_count }.from(0)
            .and not_change { offices[1].reload.reports_rejected_count }.from(0)
            .and not_change { offices[2].reload.reports_rejected_count }.from(0)
        end

        it "changes when rejected and transmitted report in approved package is undiscarded" do
          report.touch(:rejected_at, :discarded_at) and report.package.touch(:transmitted_at, :approved_at)

          expect { report.undiscard }
            .to      change { offices[0].reload.reports_rejected_count }.from(0).to(1)
            .and not_change { offices[1].reload.reports_rejected_count }.from(0)
            .and not_change { offices[2].reload.reports_rejected_count }.from(0)
        end

        it "doesn't change when rejected and transmitted report is deleted" do
          report.reject! and report.package.touch(:transmitted_at)

          expect { report.delete }
            .to  not_change { offices[0].reload.reports_rejected_count }.from(0)
            .and not_change { offices[1].reload.reports_rejected_count }.from(0)
            .and not_change { offices[2].reload.reports_rejected_count }.from(0)
        end

        it "changes when rejected and transmitted report in approved package is deleted" do
          report.reject! and report.package.touch(:transmitted_at, :approved_at)

          expect { report.delete }
            .to      change { offices[0].reload.reports_rejected_count }.from(1).to(0)
            .and not_change { offices[1].reload.reports_rejected_count }.from(0)
            .and not_change { offices[2].reload.reports_rejected_count }.from(0)
        end
      end

      describe "#reports_debated_count" do
        let(:report) { create(:report, :reported_for_office, office: offices[0]) }

        it "doesn't change on report creation" do
          expect { report }
            .to  not_change { offices[0].reload.reports_debated_count }.from(0)
            .and not_change { offices[1].reload.reports_debated_count }.from(0)
            .and not_change { offices[2].reload.reports_debated_count }.from(0)
        end

        it "doesn't change when transmitted report is debated" do
          report.package.touch(:transmitted_at)

          expect { report.debate! }
            .to  not_change { offices[0].reload.reports_debated_count }.from(0)
            .and not_change { offices[1].reload.reports_debated_count }.from(0)
            .and not_change { offices[2].reload.reports_debated_count }.from(0)
        end

        it "changes when transmitted report in approved package is debated" do
          report.package.touch(:transmitted_at, :approved_at)

          expect { report.debate! }
            .to      change { offices[0].reload.reports_debated_count }.from(0).to(1)
            .and not_change { offices[1].reload.reports_debated_count }.from(0)
            .and not_change { offices[2].reload.reports_debated_count }.from(0)
        end

        it "doesn't change when debated and transmitted report is discarded" do
          report.debate! and report.package.touch(:transmitted_at)

          expect { report.discard }
            .to  not_change { offices[0].reload.reports_debated_count }.from(0)
            .and not_change { offices[1].reload.reports_debated_count }.from(0)
            .and not_change { offices[2].reload.reports_debated_count }.from(0)
        end

        it "changes when debated and transmitted report in approved package is discarded" do
          report.debate! and report.package.touch(:transmitted_at, :approved_at)

          expect { report.discard }
            .to      change { offices[0].reload.reports_debated_count }.from(1).to(0)
            .and not_change { offices[1].reload.reports_debated_count }.from(0)
            .and not_change { offices[2].reload.reports_debated_count }.from(0)
        end

        it "doesn't change when debated and transmitted report is undiscarded" do
          report.touch(:debated_at, :discarded_at) and report.package.touch(:transmitted_at)

          expect { report.undiscard }
            .to  not_change { offices[0].reload.reports_debated_count }.from(0)
            .and not_change { offices[1].reload.reports_debated_count }.from(0)
            .and not_change { offices[2].reload.reports_debated_count }.from(0)
        end

        it "changes when debated and transmitted report in approved package is undiscarded" do
          report.touch(:debated_at, :discarded_at) and report.package.touch(:transmitted_at, :approved_at)

          expect { report.undiscard }
            .to      change { offices[0].reload.reports_debated_count }.from(0).to(1)
            .and not_change { offices[1].reload.reports_debated_count }.from(0)
            .and not_change { offices[2].reload.reports_debated_count }.from(0)
        end

        it "doesn't change when debated and transmitted report is deleted" do
          report.debate! and report.package.touch(:transmitted_at)

          expect { report.delete }
            .to  not_change { offices[0].reload.reports_debated_count }.from(0)
            .and not_change { offices[1].reload.reports_debated_count }.from(0)
            .and not_change { offices[2].reload.reports_debated_count }.from(0)
        end

        it "changes when debated and transmitted report in approved package is deleted" do
          report.debate! and report.package.touch(:transmitted_at, :approved_at)

          expect { report.delete }
            .to      change { offices[0].reload.reports_debated_count }.from(1).to(0)
            .and not_change { offices[1].reload.reports_debated_count }.from(0)
            .and not_change { offices[2].reload.reports_debated_count }.from(0)
        end
      end
    end
  end
end
