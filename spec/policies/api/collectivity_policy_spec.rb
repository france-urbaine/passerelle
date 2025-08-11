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
  it { expect(:show?).to  be_an_alias_of(policy, :not_supported?) }

  describe "relation scope" do
    subject(:scope) { apply_relation_scope(Collectivity.all) }

    it "scopes on collectivities owned_by publisher" do
      expect {
        scope.load
      }.to perform_sql_query(<<~SQL)
        SELECT "collectivities".*
        FROM   "collectivities"
        WHERE  "collectivities"."publisher_id" = '#{current_publisher.id}'
      SQL
    end
  end
end
