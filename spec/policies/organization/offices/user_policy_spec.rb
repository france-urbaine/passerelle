# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organization::Offices::UserPolicy, type: :policy do
  let(:office)  { build_stubbed(:office) }
  let(:context) { { user: current_user, office: office } }

  shared_context "when using the current user's office" do
    let(:office) do
      (current_user.office_users.any? && current_user.office_users.first.office) ||
        build(:office)
    end
  end

  shared_context "when the record is in the office", stub_factories: false do
    let(:record) { create(:user, :with_office, office:, organization: current_organization) }
  end

  describe_rule :manage? do
    context "without record" do
      let(:record) { User }

      it_behaves_like("when current user is a super admin")        { failed }
      it_behaves_like("when current user is a DDFIP admin")        { succeed }
      it_behaves_like("when current user is a DDFIP supervisor")   { failed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }

      context "without office in context" do
        let(:context) { super().without(:office) }

        it_behaves_like("when current user is a super admin")        { failed }
        it_behaves_like("when current user is a DDFIP admin")        { succeed }
        it_behaves_like("when current user is a DDFIP supervisor")   { succeed }
        it_behaves_like("when current user is a DDFIP user")         { failed }
        it_behaves_like("when current user is a publisher admin")    { failed }
        it_behaves_like("when current user is a publisher user")     { failed }
        it_behaves_like("when current user is a collectivity admin") { failed }
        it_behaves_like("when current user is a collectivity user")  { failed }
      end

      it_behaves_like "when using the current user's office" do
        it_behaves_like("when current user is a super admin")        { failed }
        it_behaves_like("when current user is a DDFIP admin")        { succeed }
        it_behaves_like("when current user is a DDFIP supervisor")   { succeed }
        it_behaves_like("when current user is a DDFIP user")         { failed }
        it_behaves_like("when current user is a publisher admin")    { failed }
        it_behaves_like("when current user is a publisher user")     { failed }
        it_behaves_like("when current user is a collectivity admin") { failed }
        it_behaves_like("when current user is a collectivity user")  { failed }
      end
    end

    context "with an user" do
      let(:record) { build_stubbed(:user) }

      it_behaves_like("when current user is a super admin")        { failed }
      it_behaves_like("when current user is a DDFIP admin")        { failed }
      it_behaves_like("when current user is a DDFIP supervisor")   { failed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }

      context "without office in context" do
        let(:context) { super().without(:office) }

        it_behaves_like("when current user is a super admin")        { failed }
        it_behaves_like("when current user is a DDFIP admin")        { failed }
        it_behaves_like("when current user is a DDFIP supervisor")   { failed }
        it_behaves_like("when current user is a DDFIP user")         { failed }
        it_behaves_like("when current user is a publisher admin")    { failed }
        it_behaves_like("when current user is a publisher user")     { failed }
        it_behaves_like("when current user is a collectivity admin") { failed }
        it_behaves_like("when current user is a collectivity user")  { failed }
      end

      it_behaves_like "when using the current user's office" do
        it_behaves_like("when current user is a super admin")        { failed }
        it_behaves_like("when current user is a DDFIP admin")        { failed }
        it_behaves_like("when current user is a DDFIP supervisor")   { failed }
        it_behaves_like("when current user is a DDFIP user")         { failed }
        it_behaves_like("when current user is a publisher admin")    { failed }
        it_behaves_like("when current user is a publisher user")     { failed }
        it_behaves_like("when current user is a collectivity admin") { failed }
        it_behaves_like("when current user is a collectivity user")  { failed }
      end
    end

    context "with a member of the current organization" do
      let(:record) { build_stubbed(:user, organization: current_organization) }

      it_behaves_like("when current user is a super admin")        { failed }
      it_behaves_like("when current user is a DDFIP admin")        { succeed }
      it_behaves_like("when current user is a DDFIP supervisor")   { failed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }

      it_behaves_like "when using the current user's office" do
        it_behaves_like "when the record is in the office" do
          it_behaves_like("when current user is a DDFIP admin")      { succeed }
          it_behaves_like("when current user is a DDFIP supervisor") { succeed }
          it_behaves_like("when current user is a DDFIP user")       { failed }
        end
      end

      context "without office in context" do
        let(:context) { super().without(:office) }

        it_behaves_like("when current user is a super admin")        { failed }
        it_behaves_like("when current user is a DDFIP admin")        { succeed }
        it_behaves_like("when current user is a DDFIP supervisor")   { failed }
        it_behaves_like("when current user is a DDFIP user")         { failed }
        it_behaves_like("when current user is a publisher admin")    { failed }
        it_behaves_like("when current user is a publisher user")     { failed }
        it_behaves_like("when current user is a collectivity admin") { failed }
        it_behaves_like("when current user is a collectivity user")  { failed }

        it_behaves_like "when using the current user's office" do
          it_behaves_like "when the record is in the office" do
            it_behaves_like("when current user is a super admin")        { failed }
            it_behaves_like("when current user is a DDFIP admin")        { succeed }
            it_behaves_like("when current user is a DDFIP supervisor")   { succeed }
          end
        end
      end

      it_behaves_like "when using the current user's office" do
        it_behaves_like("when current user is a super admin")        { failed }
        it_behaves_like("when current user is a DDFIP admin")        { succeed }
        it_behaves_like("when current user is a DDFIP supervisor")   { failed }
        it_behaves_like("when current user is a DDFIP user")         { failed }
        it_behaves_like("when current user is a publisher admin")    { failed }
        it_behaves_like("when current user is a publisher user")     { failed }
        it_behaves_like("when current user is a collectivity admin") { failed }
        it_behaves_like("when current user is a collectivity user")  { failed }

        it_behaves_like "when the record is in the office" do
          it_behaves_like("when current user is a super admin")        { failed }
          it_behaves_like("when current user is a DDFIP admin")        { succeed }
          it_behaves_like("when current user is a DDFIP supervisor")   { succeed }
          it_behaves_like("when current user is a DDFIP user")         { failed }
          it_behaves_like("when current user is a publisher admin")    { failed }
          it_behaves_like("when current user is a publisher user")     { failed }
          it_behaves_like("when current user is a collectivity admin") { failed }
          it_behaves_like("when current user is a collectivity user")  { failed }
        end
      end
    end
  end

  it { expect(:index?).to         be_an_alias_of(policy, :manage?) }
  it { expect(:new?).to           be_an_alias_of(policy, :manage?) }
  it { expect(:create?).to        be_an_alias_of(policy, :manage?) }
  it { expect(:remove?).to        be_an_alias_of(policy, :manage?) }
  it { expect(:destroy?).to       be_an_alias_of(policy, :manage?) }
  it { expect(:remove_all?).to    be_an_alias_of(policy, :manage?) }
  it { expect(:destroy_all?).to   be_an_alias_of(policy, :manage?) }
  it { expect(:edit_all?).to      be_an_alias_of(policy, :manage?) }
  it { expect(:update_all?).to    be_an_alias_of(policy, :manage?) }

  it { expect(:show?).to          be_an_alias_of(policy, :not_supported?) }
  it { expect(:edit?).to          be_an_alias_of(policy, :not_supported?) }
  it { expect(:update?).to        be_an_alias_of(policy, :not_supported?) }
  it { expect(:undiscard?).to     be_an_alias_of(policy, :not_supported?) }
  it { expect(:undiscard_all?).to be_an_alias_of(policy, :not_supported?) }
end
