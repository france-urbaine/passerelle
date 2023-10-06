# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::CollectivityPolicy, type: :policy do
  let(:current_publisher) { build_stubbed(:publisher) }
  let(:context)           { { user: nil, publisher: current_publisher } }

  describe_rule :read? do
    succeed "without record" do
      let(:record) { Collectivity }
    end

    succeed "with collectivity is owned by current publisher" do
      let(:record) { build_stubbed(:collectivity, publisher: current_publisher) }
    end

    failed "with collectivity not owned by current publisher" do
      let(:record) { build_stubbed(:collectivity) }
    end
  end

  it { expect(:index?).to be_an_alias_of(policy, :read?) }
  it { expect(:show?).to  be_an_alias_of(policy, :not_supported) }
end
