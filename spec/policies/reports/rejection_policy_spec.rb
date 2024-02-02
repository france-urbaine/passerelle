# frozen_string_literal: true

require "rails_helper"
require_relative "shared_example_for_target_office"

RSpec.describe Reports::RejectionPolicy, type: :policy do
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

  describe "params scope" do
    subject(:params) { apply_params_scope(attributes) }

    let(:attributes) do
      {
        form_type: "occupation_local_habitation",
        ddfip_id:  "50bd3322-5f43-4785-88cd-b05772c093fa",
        office_id: "13420f31-3ac6-4b7e-858d-d5df8866f117",
        reponse:   "Lorem lispum"
      }
    end

    it_behaves_like "when current user is a DDFIP admin" do
      it do
        is_expected.to include(
          reponse: "Lorem lispum"
        ).and not_include(
          :form_type,
          :ddfip_id,
          :office_id
        )
      end
    end

    it_behaves_like "when current user is a DDFIP user" do
      it do
        is_expected.to include(
          reponse: "Lorem lispum"
        ).and not_include(
          :form_type,
          :ddfip_id,
          :office_id
        )
      end
    end

    it_behaves_like("when current user is a publisher admin")    { it { is_expected.to be_nil } }
    it_behaves_like("when current user is a publisher user")     { it { is_expected.to be_nil } }
    it_behaves_like("when current user is a collectivity admin") { it { is_expected.to be_nil } }
    it_behaves_like("when current user is a collectivity user")  { it { is_expected.to be_nil } }
  end
end
