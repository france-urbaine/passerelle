# frozen_string_literal: true

require "rails_helper"

RSpec.describe Collectivities::OfficePolicy do
  describe_rule :index? do
    it_behaves_like("when current user is a super admin")        { succeed }
    it_behaves_like("when current user is a DDFIP admin")        { failed }
    it_behaves_like("when current user is a DDFIP user")         { failed }
    it_behaves_like("when current user is a publisher admin")    { succeed }
    it_behaves_like("when current user is a publisher user")     { succeed }
    it_behaves_like("when current user is a collectivity admin") { failed }
    it_behaves_like("when current user is a collectivity user")  { failed }
  end

  describe "relation scope" do
    # The following tests will assert a list of attributes rather than of a list
    # of records to produce lighter and readable output.
    #
    subject do
      policy.apply_scope(target, type: :active_record_relation).pluck(:name)
    end

    # The scope is ordered to have a deterministic order
    #
    let(:target) { Office.order(:name) }

    before do
      [
        create(:office, name: "A"),
        create(:office, name: "B")
      ]
    end

    it_behaves_like("when current user is a super admin") do
      it { is_expected.to eq(%w[A B]) }
    end

    it_behaves_like("when current user is a DDFIP admin") do
      it { is_expected.to be_empty }
    end

    it_behaves_like("when current user is a publisher admin") do
      it { is_expected.to eq(%w[A B]) }
    end

    it_behaves_like("when current user is a collectivity admin") do
      it { is_expected.to be_empty }
    end

    it_behaves_like("when current user is a DDFIP user") do
      it { is_expected.to be_empty }
    end

    it_behaves_like("when current user is a publisher user") do
      it { is_expected.to eq(%w[A B]) }
    end

    it_behaves_like("when current user is a collectivity user") do
      it { is_expected.to be_empty }
    end
  end
end
