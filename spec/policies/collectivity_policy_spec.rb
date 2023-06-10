# frozen_string_literal: true

require "rails_helper"

RSpec.describe CollectivityPolicy do
  describe_rule :index? do
    it_behaves_like("when current user is a super admin")        { succeed }
    it_behaves_like("when current user is a DDFIP admin")        { failed }
    it_behaves_like("when current user is a DDFIP user")         { failed }
    it_behaves_like("when current user is a publisher admin")    { succeed }
    it_behaves_like("when current user is a publisher user")     { succeed }
    it_behaves_like("when current user is a collectivity admin") { failed }
    it_behaves_like("when current user is a collectivity user")  { failed }
  end

  it { expect(:new?).to    be_an_alias_of(policy, :index?) }
  it { expect(:create?).to be_an_alias_of(policy, :index?) }

  it { expect(:destroy_all?).to   be_an_alias_of(policy, :index?) }
  it { expect(:remove_all?).to    be_an_alias_of(policy, :index?) }
  it { expect(:undiscard_all?).to be_an_alias_of(policy, :index?) }

  describe_rule :manage? do
    context "without record" do
      let(:record) { Collectivity }

      it_behaves_like("when current user is a super admin")        { succeed }
      it_behaves_like("when current user is a DDFIP admin")        { failed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { succeed }
      it_behaves_like("when current user is a publisher user")     { succeed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "with record" do
      let(:record) { build_stubbed(:collectivity) }

      it_behaves_like("when current user is a super admin")        { succeed }
      it_behaves_like("when current user is a DDFIP admin")        { failed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "when record is owned by the current publisher" do
      let(:record) { build_stubbed(:collectivity, publisher: current_organization) }

      it_behaves_like("when current user is a publisher admin") { succeed }
      it_behaves_like("when current user is a publisher user")  { succeed }
    end
  end

  it { expect(:update?).to be_an_alias_of(policy, :manage?) }
  it { expect(:edit?).to   be_an_alias_of(policy, :manage?) }

  it { expect(:destroy?).to   be_an_alias_of(policy, :manage?) }
  it { expect(:remove?).to    be_an_alias_of(policy, :manage?) }
  it { expect(:undiscard?).to be_an_alias_of(policy, :manage?) }

  describe "relation scope", stub_factories: false do
    # The following tests will assert a list of attributes rather than of a list
    # of records to produce lighter and readable output.
    subject do
      policy.apply_scope(target, type: :active_record_relation).pluck(:name)
    end

    # The scope is ordered to have a deterministic order
    #
    let(:target) { Collectivity.order(:name) }

    before do
      create(:collectivity, name: "A")
      create(:collectivity, name: "B")
      create(:collectivity, name: "C", publisher: current_organization) if current_organization.is_a?(Publisher)
    end

    it_behaves_like("when current user is a super admin") do
      # Create a publisher super admin to ensure its collectivities are included
      let(:current_user) { create(:user, :super_admin, :publisher) }

      it { is_expected.to eq(%w[A B C]) }
    end

    it_behaves_like("when current user is a DDFIP admin")        { it { is_expected.to be_empty } }
    it_behaves_like("when current user is a publisher admin")    { it { is_expected.to eq(%w[C]) } }
    it_behaves_like("when current user is a collectivity admin") { it { is_expected.to be_empty } }
    it_behaves_like("when current user is a DDFIP user")         { it { is_expected.to be_empty } }
    it_behaves_like("when current user is a publisher user")     { it { is_expected.to eq(%w[C]) } }
    it_behaves_like("when current user is a collectivity user")  { it { is_expected.to be_empty } }
  end

  describe "params scope" do
    # It's easier to assert the hash representation, not the ActionController::Params object
    subject do
      policy.apply_scope(target, type: :action_controller_params).to_hash.symbolize_keys
    end

    let(:target) { ActionController::Parameters.new(attributes) }
    let(:attributes) do
      {
        publisher_id:       "f4e6854a-00fb-48c4-b669-5f0623e07778",
        territory_type:     "EPCI",
        territory_id:       "738569d4-1761-4a99-8bbc-7f40aa243fce",
        territory_data:     { type: "EPCI", id: "738569d4-1761-4a99-8bbc-7f40aa243fce" }.to_json,
        territory_code:     "123456789",
        name:               "CA du Pays Basque",
        siren:              "123456789",
        contact_first_name: "Christelle",
        contact_last_name:  "Droitier",
        contact_email:      "christelle.droitier@pays-basque.fr",
        contact_phone:      "+0000"
      }
    end

    it_behaves_like("when current user is a super admin") do
      it { is_expected.to eq(attributes) }
    end

    it_behaves_like("when current user is a publisher admin") do
      it do
        is_expected.to eq(
          territory_type:     "EPCI",
          territory_id:       "738569d4-1761-4a99-8bbc-7f40aa243fce",
          territory_data:     { type: "EPCI", id: "738569d4-1761-4a99-8bbc-7f40aa243fce" }.to_json,
          territory_code:     "123456789",
          name:               "CA du Pays Basque",
          siren:              "123456789",
          contact_first_name: "Christelle",
          contact_last_name:  "Droitier",
          contact_email:      "christelle.droitier@pays-basque.fr",
          contact_phone:      "+0000"
        )
      end
    end

    it_behaves_like("when current user is a publisher user") do
      it do
        is_expected.to eq(
          territory_type:     "EPCI",
          territory_id:       "738569d4-1761-4a99-8bbc-7f40aa243fce",
          territory_data:     { type: "EPCI", id: "738569d4-1761-4a99-8bbc-7f40aa243fce" }.to_json,
          territory_code:     "123456789",
          name:               "CA du Pays Basque",
          siren:              "123456789",
          contact_first_name: "Christelle",
          contact_last_name:  "Droitier",
          contact_email:      "christelle.droitier@pays-basque.fr",
          contact_phone:      "+0000"
        )
      end
    end
  end
end
