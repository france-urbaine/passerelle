# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organization::SettingsPolicy, type: :policy do
  describe_rule :manage? do
    it_behaves_like("when current user is a super admin")        { failed }
    it_behaves_like("when current user is a DDFIP admin")        { succeed }
    it_behaves_like("when current user is a DDFIP user")         { failed }
    it_behaves_like("when current user is a publisher admin")    { succeed }
    it_behaves_like("when current user is a publisher user")     { failed }
    it_behaves_like("when current user is a collectivity admin") { succeed }
    it_behaves_like("when current user is a collectivity user")  { failed }
  end

  it { expect(:show?).to   be_an_alias_of(policy, :manage?) }
  it { expect(:edit?).to   be_an_alias_of(policy, :manage?) }
  it { expect(:update?).to be_an_alias_of(policy, :manage?) }

  describe "params scope" do
    subject(:params) { apply_params_scope(attributes) }

    let(:attributes) do
      {
        name:                "Solutions & Territoire",
        siren:               "123456789",
        contact_first_name:  "Marc",
        contact_last_name:   "Debomy",
        contact_email:       "marc.debomy@solutions-territoire.fr",
        contact_phone:       "+0000",
        allow_2fa_via_email: "true",
        domain_restriction:  "solutions-territoire.fr",
        something_else:      "true"
      }
    end

    it_behaves_like "when current user is an admin" do
      it do
        aggregate_failures do
          is_expected.to include(name:                attributes[:name])
          is_expected.to include(siren:               attributes[:siren])
          is_expected.to include(contact_first_name:  attributes[:contact_first_name])
          is_expected.to include(contact_last_name:   attributes[:contact_last_name])
          is_expected.to include(contact_email:       attributes[:contact_email])
          is_expected.to include(contact_phone:       attributes[:contact_phone])
          is_expected.to include(allow_2fa_via_email: attributes[:allow_2fa_via_email])
          is_expected.to include(domain_restriction:  attributes[:domain_restriction])
          is_expected.not_to include(:something_else)
        end
      end
    end

    it_behaves_like("when current user is a DDFIP user")         { it { is_expected.to be_nil } }
    it_behaves_like("when current user is a publisher user")     { it { is_expected.to be_nil } }
    it_behaves_like("when current user is a collectivity user")  { it { is_expected.to be_nil } }
  end
end
