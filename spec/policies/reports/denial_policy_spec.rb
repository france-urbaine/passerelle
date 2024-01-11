# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::DenialPolicy, stub_factories: false, type: :policy do
  describe_rule :manage? do
    context "without record" do
      let(:record) { Report }

      it_behaves_like("when current user is a DDFIP admin")        { succeed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
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

      context "when report is transmitted" do
        let(:record) { create(:report, :transmitted) }

        it_behaves_like("when current user is a DDFIP admin") { succeed }
      end

      context "when report is denied" do
        let(:record) { create(:report, :denied) }

        it_behaves_like("when current user is a DDFIP admin") { succeed }
      end

      context "when report is transmitted in sandbox" do
        let(:record) { create(:report, :transmitted, :sandbox) }

        it_behaves_like("when current user is a DDFIP admin") { failed }
      end

      context "when report is transmitted and discarded" do
        let(:record) { create(:report, :transmitted, :discarded) }

        it_behaves_like("when current user is a DDFIP admin") { failed }
      end

      context "when report is assigned" do
        let(:record) { create(:report, :assigned) }

        it_behaves_like("when current user is a DDFIP admin") { failed }
      end

      context "when report is not transmitted" do
        let(:record) { create(:report, :ready) }

        it_behaves_like("when current user is a DDFIP admin") { failed }
      end

      context "when report is approved" do
        let(:record) { create(:report, :approved) }

        it_behaves_like("when current user is a DDFIP admin") { failed }
      end

      context "when report is rejected" do
        let(:record) { create(:report, :rejected) }

        it_behaves_like("when current user is a DDFIP admin") { failed }
      end
    end
  end

  it { expect(:update?).to be_an_alias_of(policy, :manage?) }
  it { expect(:edit?).to be_an_alias_of(policy, :manage?) }
  it { expect(:destroy?).to be_an_alias_of(policy, :manage?) }
end
