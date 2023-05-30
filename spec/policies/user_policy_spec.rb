# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserPolicy do
  describe_rule :manage_collection? do
    it_behaves_like("when current user is a super admin")        { succeed }
    it_behaves_like("when current user is a DDFIP admin")        { succeed }
    it_behaves_like("when current user is a publisher admin")    { succeed }
    it_behaves_like("when current user is a collectivity admin") { succeed }
    it_behaves_like("when current user is a DDFIP user")         { failed }
    it_behaves_like("when current user is a publisher user")     { failed }
    it_behaves_like("when current user is a collectivity user")  { failed }
  end

  it { expect(:index?).to be_an_alias_of(policy, :manage_collection?) }
  it { expect(:create?).to be_an_alias_of(policy, :manage_collection?) }
  it { expect(:remove_all?).to be_an_alias_of(policy, :manage_collection?) }
  it { expect(:destroy_all?).to be_an_alias_of(policy, :manage_collection?) }
  it { expect(:undiscard_all?).to be_an_alias_of(policy, :manage_collection?) }

  describe_rule :manage? do
    context "without record" do
      let(:record) { User }

      it_behaves_like("when current user is a super admin")        { succeed }
      it_behaves_like("when current user is a DDFIP admin")        { succeed }
      it_behaves_like("when current user is a publisher admin")    { succeed }
      it_behaves_like("when current user is a collectivity admin") { succeed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a publisher user")     { succeed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "with record" do
      let(:record) { build_stubbed(:user) }

      it_behaves_like("when current user is a super admin")        { succeed }
      it_behaves_like("when current user is a DDFIP admin")        { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "when record is member of the current organization" do
      let(:record) { build_stubbed(:user, organization: current_organization) }

      it_behaves_like("when current user is a super admin")        { succeed }
      it_behaves_like("when current user is a DDFIP admin")        { succeed }
      it_behaves_like("when current user is a publisher admin")    { succeed }
      it_behaves_like("when current user is a collectivity admin") { succeed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "when record is member of a collectivity, owned by the current organization" do
      let(:collectivity) { build_stubbed(:collectivity, publisher: current_organization) }
      let(:record)       { build_stubbed(:user, organization: collectivity) }

      it_behaves_like("when current user is a publisher admin") { succeed }
      it_behaves_like("when current user is a publisher user")  { succeed }
    end
  end

  it { expect(:edit?).to be_an_alias_of(policy, :manage?) }
  it { expect(:update?).to be_an_alias_of(policy, :manage?) }
  it { expect(:remove?).to be_an_alias_of(policy, :manage?) }
  it { expect(:destroy?).to be_an_alias_of(policy, :manage?) }
  it { expect(:undiscard?).to be_an_alias_of(policy, :manage?) }

  describe_rule :assign_organization_admin? do
    context "without record" do
      let(:record) { User }

      it_behaves_like("when current user is a super admin")        { succeed }
      it_behaves_like("when current user is a DDFIP admin")        { succeed }
      it_behaves_like("when current user is a publisher admin")    { succeed }
      it_behaves_like("when current user is a collectivity admin") { succeed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "with record" do
      let(:record) { build_stubbed(:user) }

      it_behaves_like("when current user is a super admin")        { succeed }
      it_behaves_like("when current user is a DDFIP admin")        { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "when record is member of the current organization" do
      let(:record) { build_stubbed(:user, organization: current_organization) }

      it_behaves_like("when current user is a DDFIP admin")        { succeed }
      it_behaves_like("when current user is a publisher admin")    { succeed }
      it_behaves_like("when current user is a collectivity admin") { succeed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "when record is member of a collectivity, owned by the current organization" do
      let(:collectivity) { build_stubbed(:collectivity, publisher: current_organization) }
      let(:record)       { build_stubbed(:user, organization: collectivity) }

      it_behaves_like("when current user is a publisher admin") { succeed }
      it_behaves_like("when current user is a publisher user")  { failed }
    end
  end

  it { expect(:assign_super_admin?).to be_an_alias_of(policy, :super_admin?) }
  it { expect(:assign_organization?).to be_an_alias_of(policy, :super_admin?) }

  describe "relation scope" do
    # The following tests will assert a list of attributes rather than of a list
    # of records to produce lighter and readable output.
    subject do
      policy.apply_scope(target, type: :active_record_relation).pluck(:first_name)
    end

    # The scope is ordered to have a deterministic order
    #
    let(:target) { User.where(first_name: "A".."D").order(:first_name) }

    before do
      create(:user, first_name: "A", organization: create(:ddfip))
      create(:user, first_name: "B", organization: create(:publisher))
      create(:user, first_name: "C", organization: create(:collectivity))
      create(:user, first_name: "D", organization: current_organization)
    end

    it_behaves_like("when current user is a super admin")        { it { is_expected.to eq(%w[A B C D]) } }
    it_behaves_like("when current user is a DDFIP admin")        { it { is_expected.to eq(%w[D]) } }
    it_behaves_like("when current user is a publisher admin")    { it { is_expected.to eq(%w[D]) } }
    it_behaves_like("when current user is a collectivity admin") { it { is_expected.to eq(%w[D]) } }
    it_behaves_like("when current user is a DDFIP user")         { it { is_expected.to be_empty } }
    it_behaves_like("when current user is a publisher user")     { it { is_expected.to be_empty } }
    it_behaves_like("when current user is a collectivity user")  { it { is_expected.to be_empty } }
  end

  describe "params scope" do
    # It's easier to assert the hash representation, not the ActionController::Params object
    #
    subject do
      policy.apply_scope(target, type: :action_controller_params).to_hash.symbolize_keys
    end

    let(:target) { ActionController::Parameters.new(attributes) }
    let(:attributes) do
      {
        organization_type:  "DDFIP",
        organization_id:    "f4e6854a-00fb-48c4-b669-5f0623e07778",
        organization_data:  { type: "DDFIP", id: "f4e6854a-00fb-48c4-b669-5f0623e07778" }.to_json,
        organization_name:  "DDFIP des Pays de la Loire",
        first_name:         "Juliette",
        last_name:          "Lemoine",
        email:              "juliette.lemoine@example.org",
        organization_admin: false,
        super_admin:        false,
        office_ids:         %w[f3fabf04-eef3-4dee-989f-102b5842e18c]
      }
    end

    it_behaves_like("when current user is a super admin") do
      it { is_expected.to eq(attributes) }
    end

    it_behaves_like("when current user is a DDFIP admin") do
      it do
        is_expected.to eq(
          first_name:         "Juliette",
          last_name:          "Lemoine",
          email:              "juliette.lemoine@example.org",
          organization_admin: false,
          office_ids:         %w[f3fabf04-eef3-4dee-989f-102b5842e18c]
        )
      end
    end

    it_behaves_like("when current user is a publisher admin") do
      it do
        is_expected.to eq(
          first_name:         "Juliette",
          last_name:          "Lemoine",
          email:              "juliette.lemoine@example.org",
          organization_admin: false
        )
      end
    end

    it_behaves_like("when current user is a collectivity admin") do
      it do
        is_expected.to eq(
          first_name:         "Juliette",
          last_name:          "Lemoine",
          email:              "juliette.lemoine@example.org",
          organization_admin: false
        )
      end
    end

    it_behaves_like("when current user is a publisher user") do
      it do
        is_expected.to eq(
          first_name:         "Juliette",
          last_name:          "Lemoine",
          email:              "juliette.lemoine@example.org"
        )
      end
    end
  end
end
