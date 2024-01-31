# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::ApprovalPolicy, stub_factories: false, type: :policy do
  describe_rule :manage? do
    context "without record" do
      let(:record) { Report }

      it_behaves_like("when current user is a DDFIP admin")        { succeed }
      it_behaves_like("when current user is a DDFIP user")         { succeed }
      it_behaves_like("when current user is a DGFIP admin")        { failed }
      it_behaves_like("when current user is a DGFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "with report" do
      let(:record) { build_stubbed(:report) }

      it_behaves_like("when current user is a DDFIP admin")        { failed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a DGFIP admin")        { failed }
      it_behaves_like("when current user is a DGFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }

      context "when report is assigned" do
        let(:record) { create(:report, :assigned) }

        it_behaves_like("when current user is a DDFIP user")  { failed }
        it_behaves_like("when current user is a DDFIP admin") { failed }
      end

      context "when report is assigned to user organization" do
        let(:record) { create(:report, :assigned, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP user")  { succeed }
        it_behaves_like("when current user is a DDFIP admin") { succeed }
      end

      context "when report is approved" do
        let(:record) { create(:report, :approved, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP user")  { succeed }
        it_behaves_like("when current user is a DDFIP admin") { succeed }
      end

      context "when report is rejected" do
        let(:record) { create(:report, :rejected, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP user")  { succeed }
        it_behaves_like("when current user is a DDFIP admin") { succeed }
      end

      context "when report is transmitted" do
        let(:record) { create(:report, :transmitted, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP user")  { failed }
        it_behaves_like("when current user is a DDFIP admin") { failed }
      end

      context "when report is sandboxed" do
        let(:record) { create(:report, :assigned, :sandbox, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP user")  { failed }
        it_behaves_like("when current user is a DDFIP admin") { failed }
      end

      context "when report is discarded" do
        let(:record) { create(:report, :assigned, :discarded, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP user")  { failed }
        it_behaves_like("when current user is a DDFIP admin") { failed }
      end
    end
  end
end
