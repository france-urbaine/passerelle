# frozen_string_literal: true

require "rails_helper"
require_relative "shared_example_for_target_office"

RSpec.describe Reports::ApprovalPolicy, type: :policy do
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

      context "when transmitted to the current DDFIP" do
        let(:record) { build_stubbed(:report, :transmitted_to_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when assigned by the current DDFIP" do
        let(:record) { build_stubbed(:report, :assigned_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { succeed }
        it_behaves_like("when current user is a DDFIP user")              { succeed }
        it_behaves_like("when current user is member of targeted office") { succeed }
      end

      context "when denied by the current DDFIP" do
        let(:record) { build_stubbed(:report, :denied_by_ddfip, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { failed }
        it_behaves_like("when current user is a DDFIP user")              { failed }
        it_behaves_like("when current user is member of targeted office") { failed }
      end

      context "when approved by the current DDFIP" do
        let(:record) { build_stubbed(:report, :assigned_by_ddfip, :approved, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { succeed }
        it_behaves_like("when current user is a DDFIP user")              { succeed }
        it_behaves_like("when current user is member of targeted office") { succeed }
      end

      context "when rejected by the current DDFIP" do
        let(:record) { build_stubbed(:report, :assigned_by_ddfip, :rejected, ddfip: current_organization) }

        it_behaves_like("when current user is a DDFIP admin")             { succeed }
        it_behaves_like("when current user is a DDFIP user")              { succeed }
        it_behaves_like("when current user is member of targeted office") { succeed }
      end
    end
  end

  it { expect(:update?).to be_an_alias_of(policy, :manage?) }
  it { expect(:edit?).to be_an_alias_of(policy, :manage?) }
  it { expect(:remove?).to be_an_alias_of(policy, :manage?) }
  it { expect(:destroy?).to be_an_alias_of(policy, :manage?) }
end
