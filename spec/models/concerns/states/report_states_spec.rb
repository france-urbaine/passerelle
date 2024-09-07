# frozen_string_literal: true

require "rails_helper"

RSpec.describe States::ReportStates do
  describe Report do
    # Validations
    # ----------------------------------------------------------------------------
    describe "validations" do
      it { is_expected.to validate_presence_of(:state) }
      it { is_expected.to validate_inclusion_of(:state).in_array(described_class::STATES) }
    end

    # Scopes
    # ----------------------------------------------------------------------------
    describe "scopes" do
      describe ".draft" do
        it "scopes reports with incomplete form" do
          expect {
            described_class.draft.load
          }.to perform_sql_query(<<~SQL)
            SELECT "reports".*
            FROM   "reports"
            WHERE  "reports"."state" = 'draft'
          SQL
        end
      end

      describe ".ready" do
        it "scopes reports with completed form" do
          expect {
            described_class.ready.load
          }.to perform_sql_query(<<~SQL)
            SELECT "reports".*
            FROM   "reports"
            WHERE  "reports"."state" = 'ready'
          SQL
        end
      end

      describe ".packing" do
        it "scopes reports not yet transmitted to a DDFIP" do
          expect {
            described_class.packing.load
          }.to perform_sql_query(<<~SQL)
            SELECT "reports".*
            FROM   "reports"
            WHERE  "reports"."state" IN ('draft', 'ready')
          SQL
        end
      end

      describe ".transmitted" do
        it "scopes reports transmitted to a DDFIP" do
          expect {
            described_class.transmitted.load
          }.to perform_sql_query(<<~SQL)
            SELECT "reports".*
            FROM   "reports"
            WHERE  "reports"."state" IN ('transmitted', 'acknowledged', 'accepted', 'assigned', 'applicable', 'inapplicable', 'approved', 'canceled', 'rejected')
          SQL
        end
      end

      describe ".acknowledged" do
        it "scopes reports acknowledged by a DDFIP admin" do
          expect {
            described_class.acknowledged.load
          }.to perform_sql_query(<<~SQL)
            SELECT "reports".*
            FROM   "reports"
            WHERE  "reports"."state" IN ('acknowledged', 'accepted', 'assigned', 'applicable', 'inapplicable', 'approved', 'canceled', 'rejected')
          SQL
        end
      end

      describe ".accepted" do
        it "scopes reports accepted by a DDFIP admin" do
          expect {
            described_class.accepted.load
          }.to perform_sql_query(<<~SQL)
            SELECT "reports".*
            FROM   "reports"
            WHERE  "reports"."state" IN ('accepted', 'assigned', 'applicable', 'inapplicable', 'approved', 'canceled')
          SQL
        end
      end

      describe ".assigned" do
        it "scopes reports assigned to an office" do
          expect {
            described_class.assigned.load
          }.to perform_sql_query(<<~SQL)
            SELECT "reports".*
            FROM   "reports"
            WHERE  "reports"."state" IN ('assigned', 'applicable', 'inapplicable', 'approved', 'canceled')
          SQL
        end
      end

      describe ".resolved" do
        it "scopes reports resolved by an office" do
          expect {
            described_class.resolved.load
          }.to perform_sql_query(<<~SQL)
            SELECT "reports".*
            FROM   "reports"
            WHERE  "reports"."state" IN ('applicable', 'inapplicable', 'approved', 'canceled')
          SQL
        end
      end

      describe ".confirmed" do
        it "scopes reports confirmed by a DDFIP admin" do
          expect {
            described_class.confirmed.load
          }.to perform_sql_query(<<~SQL)
            SELECT "reports".*
            FROM   "reports"
            WHERE  "reports"."state" IN ('approved', 'canceled')
          SQL
        end
      end

      describe ".approved" do
        it "scopes reports approved by a DDFIP admin" do
          expect {
            described_class.approved.load
          }.to perform_sql_query(<<~SQL)
            SELECT "reports".*
            FROM   "reports"
            WHERE  "reports"."state" = 'approved'
          SQL
        end
      end

      describe ".canceled" do
        it "scopes reports canceled by a DDFIP admin" do
          expect {
            described_class.canceled.load
          }.to perform_sql_query(<<~SQL)
            SELECT "reports".*
            FROM   "reports"
            WHERE  "reports"."state" = 'canceled'
          SQL
        end
      end

      describe ".rejected" do
        it "scopes reports rejected by a DDFIP admin" do
          expect {
            described_class.rejected.load
          }.to perform_sql_query(<<~SQL)
            SELECT "reports".*
            FROM   "reports"
            WHERE  "reports"."state" = 'rejected'
          SQL
        end
      end

      describe ".returned" do
        it "scopes reports finished & returned to the collectivity" do
          expect {
            described_class.returned.load
          }.to perform_sql_query(<<~SQL)
            SELECT "reports".*
            FROM   "reports"
            WHERE  "reports"."state" IN ('approved', 'canceled', 'rejected')
          SQL
        end
      end

      describe ".transmittable" do
        it "scopes reports that can be transmitted to a DDFIP" do
          expect {
            described_class.transmittable.load
          }.to perform_sql_query(<<~SQL)
            SELECT "reports".*
            FROM   "reports"
            WHERE  "reports"."state" = 'ready'
          SQL
        end
      end

      describe ".acceptable" do
        it "scopes reports that can be accepted by a DDFIP admin" do
          expect {
            described_class.acceptable.load
          }.to perform_sql_query(<<~SQL)
            SELECT "reports".*
            FROM   "reports"
            WHERE  "reports"."state" IN ('transmitted', 'acknowledged', 'accepted', 'rejected')
          SQL
        end
      end

      describe ".rejectable" do
        it "scopes reports that can be rejected by a DDFIP admin" do
          expect {
            described_class.rejectable.load
          }.to perform_sql_query(<<~SQL)
            SELECT "reports".*
            FROM   "reports"
            WHERE  "reports"."state" IN ('transmitted', 'acknowledged', 'accepted', 'rejected')
          SQL
        end
      end

      describe ".assignable" do
        it "scopes reports that can be assigned to an office" do
          expect {
            described_class.assignable.load
          }.to perform_sql_query(<<~SQL)
            SELECT "reports".*
            FROM   "reports"
            WHERE  "reports"."state" IN ('accepted', 'assigned')
          SQL
        end
      end

      describe ".resolvable" do
        it "scopes reports that can be resolved by an office" do
          expect {
            described_class.resolvable.load
          }.to perform_sql_query(<<~SQL)
            SELECT "reports".*
            FROM   "reports"
            WHERE  "reports"."state" IN ('assigned', 'applicable', 'inapplicable')
          SQL
        end
      end

      describe ".confirmable" do
        it "scopes resolved reports that can be confirmed by a DDFIP admin" do
          expect {
            described_class.confirmable.load
          }.to perform_sql_query(<<~SQL)
            SELECT "reports".*
            FROM   "reports"
            WHERE  "reports"."state" IN ('applicable', 'inapplicable', 'approved', 'canceled')
          SQL
        end
      end

      describe ".waiting_for_acceptance" do
        it "scopes resolved reports that are waiting for acceptance" do
          expect {
            described_class.waiting_for_acceptance.load
          }.to perform_sql_query(<<~SQL)
            SELECT "reports".*
            FROM   "reports"
            WHERE  "reports"."state" IN ('transmitted', 'acknowledged')
          SQL
        end
      end

      describe ".waiting_for_assignment" do
        it "scopes resolved reports that are waiting for assignment" do
          expect {
            described_class.waiting_for_assignment.load
          }.to perform_sql_query(<<~SQL)
            SELECT "reports".*
            FROM   "reports"
            WHERE  "reports"."state" = 'accepted'
          SQL
        end
      end

      describe ".waiting_for_resolution" do
        it "scopes resolved reports that are waiting for resolution" do
          expect {
            described_class.waiting_for_resolution.load
          }.to perform_sql_query(<<~SQL)
            SELECT "reports".*
            FROM   "reports"
            WHERE  "reports"."state" = 'assigned'
          SQL
        end
      end

      describe ".waiting_for_confirmation" do
        it "scopes resolved reports that are waiting for confirmation" do
          expect {
            described_class.waiting_for_confirmation.load
          }.to perform_sql_query(<<~SQL)
            SELECT "reports".*
            FROM   "reports"
            WHERE  "reports"."state" IN ('applicable', 'inapplicable')
          SQL
        end
      end
    end

    # Predicates
    # ----------------------------------------------------------------------------
    describe "predicates" do
      let_it_be(:draft)                  { build_stubbed(:report, :draft) }
      let_it_be(:ready)                  { build_stubbed(:report, :ready) }
      let_it_be(:in_active_transmission) { build_stubbed(:report, :in_active_transmission) }
      let_it_be(:transmitted)            { build_stubbed(:report, :transmitted) }
      let_it_be(:acknowledged)           { build_stubbed(:report, :acknowledged) }
      let_it_be(:accepted)               { build_stubbed(:report, :accepted) }
      let_it_be(:assigned)               { build_stubbed(:report, :assigned) }
      let_it_be(:applicable)             { build_stubbed(:report, :applicable) }
      let_it_be(:inapplicable)           { build_stubbed(:report, :inapplicable) }
      let_it_be(:approved)               { build_stubbed(:report, :approved) }
      let_it_be(:canceled)               { build_stubbed(:report, :canceled) }
      let_it_be(:rejected)               { build_stubbed(:report, :rejected) }

      describe "#draft?" do
        it { expect(draft)                  .to     be_draft }
        it { expect(ready)                  .not_to be_draft }
        it { expect(in_active_transmission) .not_to be_draft }
        it { expect(transmitted)            .not_to be_draft }
      end

      describe "#ready?" do
        it { expect(draft)                  .not_to be_ready }
        it { expect(ready)                  .to     be_ready }
        it { expect(in_active_transmission) .to     be_ready }
        it { expect(transmitted)            .not_to be_ready }
      end

      describe "#packing?" do
        it { expect(draft)                  .to     be_packing }
        it { expect(ready)                  .to     be_packing }
        it { expect(in_active_transmission) .to     be_packing }
        it { expect(transmitted)            .not_to be_packing }
      end

      describe "#transmitted?" do
        it { expect(draft)                  .not_to be_transmitted }
        it { expect(ready)                  .not_to be_transmitted }
        it { expect(in_active_transmission) .not_to be_transmitted }
        it { expect(transmitted)            .to     be_transmitted }
        it { expect(accepted)               .to     be_transmitted }
        it { expect(assigned)               .to     be_transmitted }
        it { expect(approved)               .to     be_transmitted }
        it { expect(canceled)               .to     be_transmitted }
        it { expect(rejected)               .to     be_transmitted }
      end

      describe "#acknowledged?" do
        it { expect(transmitted)  .not_to be_acknowledged }
        it { expect(acknowledged) .to     be_acknowledged }
        it { expect(assigned)     .to     be_acknowledged }
        it { expect(approved)     .to     be_acknowledged }
        it { expect(canceled)     .to     be_acknowledged }
        it { expect(rejected)     .to     be_acknowledged }
      end

      describe "#accepted?" do
        it { expect(transmitted)  .not_to be_accepted }
        it { expect(accepted)     .to     be_accepted }
        it { expect(assigned)     .to     be_accepted }
        it { expect(applicable)   .to     be_accepted }
        it { expect(inapplicable) .to     be_accepted }
        it { expect(approved)     .to     be_accepted }
        it { expect(canceled)     .to     be_accepted }
        it { expect(rejected)     .not_to be_accepted }
      end

      describe "#assigned?" do
        it { expect(transmitted)  .not_to be_assigned }
        it { expect(accepted)     .not_to be_assigned }
        it { expect(assigned)     .to     be_assigned }
        it { expect(applicable)   .to     be_assigned }
        it { expect(inapplicable) .to     be_assigned }
        it { expect(approved)     .to     be_assigned }
        it { expect(canceled)     .to     be_assigned }
        it { expect(rejected)     .not_to be_assigned }
      end

      describe "#resolved?" do
        it { expect(transmitted)  .not_to be_resolved }
        it { expect(accepted)     .not_to be_resolved }
        it { expect(assigned)     .not_to be_resolved }
        it { expect(applicable)   .to     be_resolved }
        it { expect(inapplicable) .to     be_resolved }
        it { expect(approved)     .to     be_resolved }
        it { expect(canceled)     .to     be_resolved }
        it { expect(rejected)     .not_to be_resolved }
      end

      describe "#confirmed?" do
        it { expect(transmitted)  .not_to be_confirmed }
        it { expect(accepted)     .not_to be_confirmed }
        it { expect(assigned)     .not_to be_confirmed }
        it { expect(applicable)   .not_to be_confirmed }
        it { expect(inapplicable) .not_to be_confirmed }
        it { expect(approved)     .to     be_confirmed }
        it { expect(canceled)     .to     be_confirmed }
        it { expect(rejected)     .not_to be_confirmed }
      end

      describe "#approved?" do
        it { expect(transmitted)  .not_to be_approved }
        it { expect(assigned)     .not_to be_approved }
        it { expect(applicable)   .not_to be_approved }
        it { expect(approved)     .to     be_approved }
        it { expect(canceled)     .not_to be_approved }
        it { expect(rejected)     .not_to be_approved }
      end

      describe "#canceled?" do
        it { expect(transmitted)  .not_to be_canceled }
        it { expect(assigned)     .not_to be_canceled }
        it { expect(applicable)   .not_to be_canceled }
        it { expect(approved)     .not_to be_canceled }
        it { expect(canceled)     .to     be_canceled }
        it { expect(rejected)     .not_to be_canceled }
      end

      describe "#rejected?" do
        it { expect(transmitted)  .not_to be_rejected }
        it { expect(assigned)     .not_to be_rejected }
        it { expect(applicable)   .not_to be_rejected }
        it { expect(approved)     .not_to be_rejected }
        it { expect(canceled)     .not_to be_rejected }
        it { expect(rejected)     .to     be_rejected }
      end

      describe "#returned?" do
        it { expect(transmitted)  .not_to be_returned }
        it { expect(assigned)     .not_to be_returned }
        it { expect(applicable)   .not_to be_returned }
        it { expect(approved)     .to     be_returned }
        it { expect(canceled)     .to     be_returned }
        it { expect(rejected)     .to     be_returned }
      end

      describe "#transmittable?" do
        it { expect(draft)                  .not_to be_transmittable }
        it { expect(ready)                  .to     be_transmittable }
        it { expect(in_active_transmission) .to     be_transmittable }
        it { expect(transmitted)            .not_to be_transmittable }
      end

      describe "#acceptable?" do
        it { expect(transmitted)  .to     be_acceptable }
        it { expect(acknowledged) .to     be_acceptable }
        it { expect(accepted)     .to     be_acceptable }
        it { expect(assigned)     .not_to be_acceptable }
        it { expect(applicable)   .not_to be_acceptable }
        it { expect(inapplicable) .not_to be_acceptable }
        it { expect(approved)     .not_to be_acceptable }
        it { expect(canceled)     .not_to be_acceptable }
        it { expect(rejected)     .to     be_acceptable }
      end

      describe "#rejectable?" do
        it { expect(transmitted)  .to     be_rejectable }
        it { expect(acknowledged) .to     be_rejectable }
        it { expect(accepted)     .to     be_rejectable }
        it { expect(assigned)     .not_to be_rejectable }
        it { expect(applicable)   .not_to be_rejectable }
        it { expect(inapplicable) .not_to be_rejectable }
        it { expect(approved)     .not_to be_rejectable }
        it { expect(canceled)     .not_to be_rejectable }
        it { expect(rejected)     .to     be_rejectable }
      end

      describe "#assignable?" do
        it { expect(transmitted)  .not_to be_assignable }
        it { expect(acknowledged) .not_to be_assignable }
        it { expect(accepted)     .to     be_assignable }
        it { expect(assigned)     .to     be_assignable }
        it { expect(applicable)   .not_to be_assignable }
        it { expect(inapplicable) .not_to be_assignable }
        it { expect(approved)     .not_to be_assignable }
        it { expect(canceled)     .not_to be_assignable }
        it { expect(rejected)     .not_to be_assignable }
      end

      describe "#resolvable?" do
        it { expect(transmitted)  .not_to be_resolvable }
        it { expect(acknowledged) .not_to be_resolvable }
        it { expect(accepted)     .not_to be_resolvable }
        it { expect(assigned)     .to     be_resolvable }
        it { expect(applicable)   .to     be_resolvable }
        it { expect(inapplicable) .to     be_resolvable }
        it { expect(approved)     .not_to be_resolvable }
        it { expect(canceled)     .not_to be_resolvable }
        it { expect(rejected)     .not_to be_resolvable }
      end

      describe "#confirmable?" do
        it { expect(transmitted)  .not_to be_confirmable }
        it { expect(acknowledged) .not_to be_confirmable }
        it { expect(accepted)     .not_to be_confirmable }
        it { expect(assigned)     .not_to be_confirmable }
        it { expect(applicable)   .to     be_confirmable }
        it { expect(inapplicable) .to     be_confirmable }
        it { expect(approved)     .to     be_confirmable }
        it { expect(canceled)     .to     be_confirmable }
        it { expect(rejected)     .not_to be_confirmable }
      end
    end

    # Transition methods
    # ----------------------------------------------------------------------------
    describe "transition methods" do
      describe "#resume!" do
        it "updates a ready report back to draft" do
          report = create(:report, :ready)

          expect {
            report.resume!
          }.to ret(true)
            .and change(report, :state).to("draft")
            .and change(report, :completed_at).to(nil)
            .and change(report, :updated_at)
        end

        it "doesn't update an already draft report but keeps returning true" do
          report = create(:report, :draft)

          expect {
            report.resume!
          }.to ret(true)
            .and not_change(report, :state).from("draft")
            .and not_change(report, :completed_at)
            .and not_change(report, :updated_at)
        end

        it "doesn't update an already transmitted report" do
          report = create(:report, :transmitted)

          expect {
            report.resume!
          }.to ret(false)
            .and not_change(report, :state).from("transmitted")
            .and not_change(report, :completed_at)
            .and not_change(report, :updated_at)
        end
      end

      describe "#complete!" do
        it "updates a draft report to be ready" do
          report = create(:report)

          expect {
            report.complete!
          }.to ret(true)
            .and change(report, :state).to("ready")
            .and change(report, :completed_at).to(be_present)
            .and change(report, :updated_at)
        end

        it "doesn't update an already ready report but keeps returning true" do
          report = create(:report, :ready)

          expect {
            report.complete!
          }.to ret(true)
            .and not_change(report, :state).from("ready")
            .and not_change(report, :completed_at)
            .and not_change(report, :updated_at)
        end

        it "doesn't update an already transmitted report" do
          report = create(:report, :transmitted)

          expect {
            report.complete!
          }.to ret(false)
            .and not_change(report, :state).from("transmitted")
            .and not_change(report, :completed_at)
            .and not_change(report, :updated_at)
        end
      end

      describe "#transmit!" do
        it "updates a report to be transmitted" do
          report = create(:report, :ready)

          expect {
            report.transmit!
          }.to ret(true)
            .and change(report, :state).to("transmitted")
            .and change(report, :transmitted_at).to(be_present)
            .and change(report, :updated_at)
        end

        it "doesn't update an already transmitted report but keeps returning true" do
          report = create(:report, :transmitted)

          expect {
            report.transmit!
          }.to ret(true)
            .and not_change(report, :state).from("transmitted")
            .and not_change(report, :transmitted_at)
            .and not_change(report, :updated_at)
        end

        it "doesn't update an already acknowledged report" do
          report = create(:report, :acknowledged)

          expect {
            report.transmit!
          }.to ret(false)
            .and not_change(report, :state).from("acknowledged")
            .and not_change(report, :transmitted_at)
            .and not_change(report, :updated_at)
        end
      end

      describe "#acknowledge!" do
        it "updates a report to be `acknowledged`" do
          report = create(:report, :transmitted)

          expect {
            report.acknowledge!
          }.to ret(true)
            .and change(report, :state).to("acknowledged")
            .and change(report, :acknowledged_at).to(be_present)
            .and change(report, :updated_at)
        end

        it "doesn't update an already acknowledged report but keeps returning true" do
          report = create(:report, :acknowledged)

          expect {
            report.acknowledge!
          }.to ret(true)
            .and not_change(report, :state).from("acknowledged")
            .and not_change(report, :acknowledged_at)
            .and not_change(report, :updated_at)
        end

        it "doesn't update an already assigned report" do
          report = create(:report, :assigned)

          expect {
            report.acknowledge!
          }.to ret(false)
            .and not_change(report, :state).from("assigned")
            .and not_change(report, :acknowledged_at)
            .and not_change(report, :updated_at)
        end
      end

      describe "#accept!" do
        it "updates a transmitted report to be accepted" do
          report = create(:report, :transmitted)

          expect {
            report.accept!
          }.to ret(true)
            .and change(report, :state).to("accepted")
            .and change(report, :accepted_at).to(be_present)
            .and change(report, :acknowledged_at).to(be_present)
            .and change(report, :updated_at)
        end

        it "updates an acknowledged report but keep the acknowledged date" do
          report = create(:report, :acknowledged)

          expect {
            report.accept!
          }.to ret(true)
            .and change(report, :state).to("accepted")
            .and change(report, :accepted_at).to(be_present)
            .and change(report, :updated_at)
            .and not_change(report, :acknowledged_at)
        end

        it "updates a rejected report" do
          report = create(:report, :rejected)

          expect {
            report.accept!
          }.to ret(true)
            .and change(report, :state).to("accepted")
            .and change(report, :accepted_at).to(be_present)
            .and change(report, :returned_at).to(nil)
            .and change(report, :updated_at)
        end

        it "doesn't update an already accepted report but keeps returning true" do
          report = create(:report, :accepted)

          expect {
            report.accept!
          }.to ret(true)
            .and not_change(report, :state).from("accepted")
            .and not_change(report, :accepted_at)
            .and not_change(report, :updated_at)
        end

        it "doesn't update an already assigned report" do
          report = create(:report, :assigned)

          expect {
            report.accept!
          }.to ret(false)
            .and not_change(report, :state).from("assigned")
            .and not_change(report, :assigned_at)
            .and not_change(report, :updated_at)
        end
      end

      describe "#assign!" do
        it "updates an accepted report to be assigned" do
          report = create(:report, :accepted)

          expect {
            report.assign!
          }.to ret(true)
            .and change(report, :state).to("assigned")
            .and change(report, :assigned_at).to(be_present)
            .and change(report, :updated_at)
        end

        it "doesn't update an already assigned report but keeps returning true" do
          report = create(:report, :assigned)

          expect {
            report.assign!
          }.to ret(true)
            .and not_change(report, :state).from("assigned")
            .and not_change(report, :assigned_at)
            .and not_change(report, :updated_at)
        end

        it "doesn't update an already resolved report" do
          report = create(:report, :applicable)

          expect {
            report.assign!
          }.to ret(false)
            .and not_change(report, :state).from("applicable")
            .and not_change(report, :assigned_at)
            .and not_change(report, :updated_at)
        end
      end

      describe "#resolve!" do
        it "updates a report to be resolved as applicable" do
          report = create(:report, :assigned)

          expect {
            report.resolve!(:applicable)
          }.to ret(true)
            .and change(report, :state).to("applicable")
            .and change(report, :resolved_at).to(be_present)
            .and change(report, :updated_at)
        end

        it "updates a report to be resolved as inapplicable" do
          report = create(:report, :assigned)

          expect {
            report.resolve!(:inapplicable)
          }.to ret(true)
            .and change(report, :state).to("inapplicable")
            .and change(report, :resolved_at).to(be_present)
            .and change(report, :updated_at)
        end

        it "raises an error on unexpected resolved state" do
          report = create(:report, :assigned)

          expect {
            report.resolve!(:approved)
          }.to raise_error(ArgumentError)
        end

        it "updates an already resolved report to be applicable" do
          report = create(:report, :inapplicable)

          expect {
            report.resolve!(:applicable)
          }.to ret(true)
            .and change(report, :state).to("applicable")
            .and change(report, :resolved_at)
            .and change(report, :updated_at)
        end

        it "updates an already resolved report to be inapplicable" do
          report = create(:report, :applicable)

          expect {
            report.resolve!(:inapplicable)
          }.to ret(true)
            .and change(report, :state).to("inapplicable")
            .and change(report, :resolved_at)
            .and change(report, :updated_at)
        end

        it "doesn't update an already resolved report but keeps returning true" do
          report = create(:report, :applicable)

          expect {
            report.resolve!(:applicable)
          }.to ret(true)
            .and not_change(report, :state).from("applicable")
            .and not_change(report, :resolved_at)
            .and not_change(report, :updated_at)
        end

        it "doesn't update an already confirmed report" do
          report = create(:report, :approved)

          expect {
            report.resolve!(:applicable)
          }.to ret(false)
            .and not_change(report, :state).from("approved")
            .and not_change(report, :resolved_at)
            .and not_change(report, :updated_at)
        end
      end

      describe "#confirm!" do
        it "updates an applicable report to be approved" do
          report = create(:report, :applicable)

          expect {
            report.confirm!
          }.to ret(true)
            .and change(report, :state).to("approved")
            .and change(report, :returned_at).to(be_present)
            .and change(report, :updated_at)
        end

        it "updates an inapplicable report to be canceled" do
          report = create(:report, :inapplicable)

          expect {
            report.confirm!
          }.to ret(true)
            .and change(report, :state).to("canceled")
            .and change(report, :returned_at).to(be_present)
            .and change(report, :updated_at)
        end

        it "doesn't update an already confirmed report but keeps returning true" do
          report = create(:report, :approved)

          expect {
            report.confirm!
          }.to ret(true)
            .and not_change(report, :state).from("approved")
            .and not_change(report, :returned_at)
            .and not_change(report, :updated_at)
        end

        it "doesn't update a rejected report" do
          report = create(:report, :rejected)

          expect {
            report.confirm!
          }.to ret(false)
            .and not_change(report, :state).from("rejected")
            .and not_change(report, :returned_at)
            .and not_change(report, :updated_at)
        end
      end

      describe "#reject!" do
        it "updates a report to be rejected" do
          report = create(:report, :acknowledged)

          expect {
            report.reject!
          }.to ret(true)
            .and change(report, :state).to("rejected")
            .and change(report, :returned_at).to(be_present)
            .and change(report, :updated_at)
        end

        it "updates an accepted report" do
          report = create(:report, :accepted)

          expect {
            report.reject!
          }.to ret(true)
            .and change(report, :state).to("rejected")
            .and change(report, :returned_at).to(be_present)
            .and change(report, :accepted_at).to(nil)
            .and change(report, :updated_at)
        end

        it "doesn't update an already rejected report but keeps returning true" do
          report = create(:report, :rejected)

          expect {
            report.reject!
          }.to ret(true)
            .and not_change(report, :state).from("rejected")
            .and not_change(report, :returned_at)
            .and not_change(report, :updated_at)
        end

        it "doesn't update an already assigned report" do
          report = create(:report, :assigned)

          expect {
            report.reject!
          }.to ret(false)
            .and not_change(report, :state).from("assigned")
            .and not_change(report, :returned_at)
            .and not_change(report, :updated_at)
        end
      end

      describe "#undo_acceptance!" do
        it "updates an accepted report back to acknowledged" do
          report = create(:report, :accepted)

          expect {
            report.undo_acceptance!
          }.to ret(true)
            .and change(report, :state).to("acknowledged")
            .and change(report, :accepted_at).to(nil)
            .and change(report, :updated_at)
            .and not_change(report, :acknowledged_at)
        end
      end

      describe "#undo_assignment!" do
        it "updates an assigned report back to accepted" do
          report = create(:report, :assigned)

          expect {
            report.undo_assignment!
          }.to ret(true)
            .and change(report, :state).to("accepted")
            .and change(report, :assigned_at).to(nil)
            .and change(report, :updated_at)
            .and not_change(report, :acknowledged_at)
        end
      end

      describe "#undo_resolution!" do
        it "updates a rejected report back to assigned" do
          report = create(:report, :applicable)

          expect {
            report.undo_resolution!
          }.to ret(true)
            .and change(report, :state).to("assigned")
            .and change(report, :resolved_at).to(nil)
            .and change(report, :updated_at)
        end
      end

      describe "#undo_rejection!" do
        it "updates a rejected report back to acknowledged" do
          report = create(:report, :rejected)

          expect {
            report.undo_rejection!
          }.to ret(true)
            .and change(report, :state).to("acknowledged")
            .and change(report, :returned_at).to(nil)
            .and change(report, :updated_at)
        end
      end
    end

    # Transition methods
    # ----------------------------------------------------------------------------
    describe "multiple transition methods" do
      before do
        Timecop.freeze(Time.zone.local(2024, 2, 8, 16, 0))
      end

      describe ".transmit_all" do
        it "updates records as transmitted" do
          expect {
            described_class.transmit_all
          }.to perform_sql_query(<<~SQL.squish)
            UPDATE  "reports"
            SET     "state"           = 'transmitted',
                    "transmitted_at"  = (COALESCE("reports"."transmitted_at", '2024-02-08 16:00:00')),
                    "updated_at"      = '2024-02-08 16:00:00'

            WHERE   "reports"."state" = 'ready'
          SQL
        end

        it "updates with custom attributes" do
          expect {
            described_class.transmit_all(
              transmitted_at: Time.zone.local(2024, 1, 15),
              priority:       "high"
            )
          }.to perform_sql_query(<<~SQL.squish)
            UPDATE  "reports"
            SET     "transmitted_at"  = '2024-01-15 00:00:00',
                    "priority"        = 'high',
                    "state"           = 'transmitted',
                    "updated_at"      = '2024-02-08 16:00:00'

            WHERE   "reports"."state" = 'ready'
          SQL
        end

        it "sanitizes custom attributes" do
          expect {
            described_class.transmit_all(
              state:          "approved",
              transmitted_at: "2024-01-15 00:00:00') OR 1=1--"
            )
          }.to perform_sql_query(<<~SQL.squish)
            UPDATE  "reports"
            SET     "state"           = 'transmitted',
                    "transmitted_at"  = '2024-01-15 00:00:00',
                    "updated_at"      = '2024-02-08 16:00:00'

            WHERE   "reports"."state" = 'ready'
          SQL
        end
      end

      describe ".accept_all" do
        it "updates records as accepted" do
          expect {
            described_class.accept_all
          }.to perform_sql_query(<<~SQL.squish)
            UPDATE  "reports"
            SET     "state"           = 'accepted',
                    "acknowledged_at" = (COALESCE("reports"."acknowledged_at", '2024-02-08 16:00:00')),
                    "accepted_at"     = (COALESCE("reports"."accepted_at", '2024-02-08 16:00:00')),
                    "returned_at"     = NULL,
                    "updated_at"      = '2024-02-08 16:00:00'

            WHERE   "reports"."state" IN ('transmitted', 'acknowledged', 'accepted', 'rejected')
          SQL
        end

        it "updates with custom attributes" do
          expect {
            described_class.accept_all(
              accepted_at: Time.zone.local(2024, 1, 15),
              priority:    "high"
            )
          }.to perform_sql_query(<<~SQL.squish)
            UPDATE  "reports"
            SET     "accepted_at"     = '2024-01-15 00:00:00',
                    "priority"        = 'high',
                    "state"           = 'accepted',
                    "acknowledged_at" = (COALESCE("reports"."acknowledged_at", '2024-02-08 16:00:00')),
                    "returned_at"     = NULL,
                    "updated_at"      = '2024-02-08 16:00:00'

            WHERE   "reports"."state" IN ('transmitted', 'acknowledged', 'accepted', 'rejected')
          SQL
        end

        it "sanitizes custom attributes" do
          expect {
            described_class.accept_all(
              state:       "approved",
              accepted_at: "2024-01-15 00:00:00) OR 1=1--"
            )
          }.to perform_sql_query(<<~SQL.squish)
            UPDATE  "reports"
            SET     "state"           = 'accepted',
                    "accepted_at"     = '2024-01-15 00:00:00',
                    "acknowledged_at" = (COALESCE("reports"."acknowledged_at", '2024-02-08 16:00:00')),
                    "returned_at"     = NULL,
                    "updated_at"      = '2024-02-08 16:00:00'

            WHERE   "reports"."state" IN ('transmitted', 'acknowledged', 'accepted', 'rejected')
          SQL
        end
      end

      describe ".assign_all" do
        it "updates records as assigned" do
          expect {
            described_class.assign_all
          }.to perform_sql_query(<<~SQL.squish)
            UPDATE  "reports"
            SET     "state"       = 'assigned',
                    "assigned_at" = (COALESCE("reports"."assigned_at", '2024-02-08 16:00:00')),
                    "updated_at"  = '2024-02-08 16:00:00'

            WHERE   "reports"."state" IN ('accepted', 'assigned')
          SQL
        end

        it "updates with custom attributes" do
          expect {
            described_class.assign_all(
              assigned_at: Time.zone.local(2024, 1, 15),
              priority:    "high"
            )
          }.to perform_sql_query(<<~SQL.squish)
            UPDATE  "reports"
            SET     "assigned_at" = '2024-01-15 00:00:00',
                    "priority"    = 'high',
                    "state"       = 'assigned',
                    "updated_at"  = '2024-02-08 16:00:00'

            WHERE   "reports"."state" IN ('accepted', 'assigned')
          SQL
        end

        it "sanitizes custom attributes" do
          expect {
            described_class.assign_all(
              state:       "approved",
              assigned_at: "2024-01-15 00:00:00) OR 1=1--"
            )
          }.to perform_sql_query(<<~SQL.squish)
            UPDATE  "reports"
            SET     "state"       = 'assigned',
                    "assigned_at" = '2024-01-15 00:00:00',
                    "updated_at"  = '2024-02-08 16:00:00'

            WHERE   "reports"."state" IN ('accepted', 'assigned')
          SQL
        end
      end

      describe ".reject_all" do
        it "updates records as rejected" do
          expect {
            described_class.reject_all
          }.to perform_sql_query(<<~SQL.squish)
            UPDATE  "reports"
            SET     "state"           = 'rejected',
                    "acknowledged_at" = (COALESCE("reports"."acknowledged_at", '2024-02-08 16:00:00')),
                    "returned_at"     = (COALESCE("reports"."returned_at", '2024-02-08 16:00:00')),
                    "accepted_at"     = NULL,
                    "updated_at"      = '2024-02-08 16:00:00'

            WHERE   "reports"."state" IN ('transmitted', 'acknowledged', 'accepted', 'rejected')
          SQL
        end

        it "updates with custom attributes" do
          expect {
            described_class.reject_all(
              returned_at: Time.zone.local(2024, 1, 15),
              priority:    "high"
            )
          }.to perform_sql_query(<<~SQL.squish)
            UPDATE  "reports"
            SET     "returned_at"     = '2024-01-15 00:00:00',
                    "priority"        = 'high',
                    "state"           = 'rejected',
                    "acknowledged_at" = (COALESCE("reports"."acknowledged_at", '2024-02-08 16:00:00')),
                    "accepted_at"     = NULL,
                    "updated_at"      = '2024-02-08 16:00:00'

            WHERE   "reports"."state" IN ('transmitted', 'acknowledged', 'accepted', 'rejected')
          SQL
        end

        it "sanitizes custom attributes" do
          expect {
            described_class.reject_all(
              state:       "approved",
              returned_at: "2024-01-15 00:00:00) OR 1=1--"
            )
          }.to perform_sql_query(<<~SQL.squish)
            UPDATE  "reports"
            SET     "state"           = 'rejected',
                    "returned_at"     = '2024-01-15 00:00:00',
                    "acknowledged_at" = (COALESCE("reports"."acknowledged_at", '2024-02-08 16:00:00')),
                    "accepted_at"     = NULL,
                    "updated_at"      = '2024-02-08 16:00:00'

            WHERE   "reports"."state" IN ('transmitted', 'acknowledged', 'accepted', 'rejected')
          SQL
        end
      end

      describe ".resolve_all" do
        it "updates records as applicable" do
          expect {
            described_class.resolve_all("applicable")
          }.to perform_sql_query(<<~SQL.squish)
            UPDATE  "reports"
            SET     "state"       = 'applicable',
                    "resolved_at" = (COALESCE("reports"."resolved_at", '2024-02-08 16:00:00')),
                    "updated_at"  = '2024-02-08 16:00:00'

            WHERE   "reports"."state" IN ('assigned', 'applicable', 'inapplicable')
          SQL
        end

        it "updates records as inapplicable" do
          expect {
            described_class.resolve_all("inapplicable")
          }.to perform_sql_query(<<~SQL.squish)
            UPDATE  "reports"
            SET     "state"       = 'inapplicable',
                    "resolved_at" = (COALESCE("reports"."resolved_at", '2024-02-08 16:00:00')),
                    "updated_at"  = '2024-02-08 16:00:00'

            WHERE   "reports"."state" IN ('assigned', 'applicable', 'inapplicable')
          SQL
        end

        it "rejects invalid states" do
          expect {
            described_class.resolve_all("approved")
          }.to raise_exception(ArgumentError)
        end

        it "updates with custom attributes" do
          expect {
            described_class.resolve_all(
              "applicable",
              resolved_at: Time.zone.local(2024, 1, 15),
              priority:    "high"
            )
          }.to perform_sql_query(<<~SQL.squish)
            UPDATE  "reports"
            SET     "resolved_at" = '2024-01-15 00:00:00',
                    "priority"    = 'high',
                    "state"       = 'applicable',
                    "updated_at"  = '2024-02-08 16:00:00'

            WHERE   "reports"."state" IN ('assigned', 'applicable', 'inapplicable')
          SQL
        end

        it "sanitizes custom attributes" do
          expect {
            described_class.resolve_all(
              "applicable",
              state:       "approved",
              resolved_at: "2024-01-15 00:00:00) OR 1=1--"
            )
          }.to perform_sql_query(<<~SQL.squish)
            UPDATE  "reports"
            SET     "state"           = 'applicable',
                    "resolved_at"     = '2024-01-15 00:00:00',
                    "updated_at"  = '2024-02-08 16:00:00'

            WHERE   "reports"."state" IN ('assigned', 'applicable', 'inapplicable')
          SQL
        end
      end

      describe ".confirm_all" do
        it "updates records as approved or canceled according to their current state" do
          expect {
            described_class.confirm_all
          }.to perform_sql_query(<<~SQL.squish)
            UPDATE  "reports"
            SET     "state"       = (
                      CASE "reports"."state"
                      WHEN 'applicable'::report_state   THEN 'approved'::report_state
                      WHEN 'inapplicable'::report_state THEN 'canceled'::report_state
                      ELSE "reports"."state"
                      END
                    ),
                    "returned_at" = (COALESCE("reports"."returned_at", '2024-02-08 16:00:00')),
                    "updated_at"  = '2024-02-08 16:00:00'

            WHERE   "reports"."state" IN ('applicable', 'inapplicable', 'approved', 'canceled')
          SQL
        end

        it "updates with custom attributes" do
          expect {
            described_class.confirm_all(
              returned_at: Time.zone.local(2024, 1, 15),
              priority:    "high"
            )
          }.to perform_sql_query(<<~SQL.squish)
            UPDATE  "reports"
            SET     "returned_at" = '2024-01-15 00:00:00',
                    "priority"    = 'high',
                    "state"       = (
                      CASE "reports"."state"
                      WHEN 'applicable'::report_state   THEN 'approved'::report_state
                      WHEN 'inapplicable'::report_state THEN 'canceled'::report_state
                      ELSE "reports"."state"
                      END
                    ),
                    "updated_at"  = '2024-02-08 16:00:00'

            WHERE   "reports"."state" IN ('applicable', 'inapplicable', 'approved', 'canceled')
          SQL
        end

        it "sanitizes custom attributes" do
          expect {
            described_class.confirm_all(
              state:       "approved",
              returned_at: "2024-01-15 00:00:00) OR 1=1--"
            )
          }.to perform_sql_query(<<~SQL.squish)
            UPDATE  "reports"
            SET     "state" = (
                      CASE "reports"."state"
                      WHEN 'applicable'::report_state   THEN 'approved'::report_state
                      WHEN 'inapplicable'::report_state THEN 'canceled'::report_state
                      ELSE "reports"."state"
                      END
                    ),
                    "returned_at" = '2024-01-15 00:00:00',
                    "updated_at"  = '2024-02-08 16:00:00'

            WHERE   "reports"."state" IN ('applicable', 'inapplicable', 'approved', 'canceled')
          SQL
        end
      end
    end
  end
end
