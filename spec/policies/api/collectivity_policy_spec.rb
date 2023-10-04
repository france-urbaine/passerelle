# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::CollectivityPolicy, stub_factories: false do
  let!(:publisher) { create(:publisher) }
  let(:context) { { user: nil, publisher: publisher } }
  let(:collectivity) { create(:collectivity, publisher: publisher) }

  describe_rule :create? do
    let(:record) { collectivity }

    succeed "when collectivitiy is listed to publisher"
    failed "when collectivity is not listed to publisher" do
      let(:record) { create(:collectivity) }
    end
  end
end
