# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::TransmissionPolicy, type: :policy do
  let(:current_publisher) { build_stubbed(:publisher) }
  let(:context)           { { user: nil, publisher: current_publisher } }

  describe_rule :create? do
    succeed "without record" do
      let(:record) { Transmission }
    end
  end

  describe_rule :read?, stub_factories: false do
    let(:current_publisher) { create(:publisher) }

    succeed "without record" do
      let(:record) { Transmission }
    end

    succeed "with transmission owned by current publisher" do
      let(:record) { create(:transmission, :made_through_api, :with_reports, publisher: current_publisher) }

      succeed "when already completed" do
        let(:record) { create(:transmission, :made_through_api, :completed, publisher: current_publisher) }
      end

      succeed "without reports" do
        let(:record) { create(:transmission, :made_through_api, publisher: current_publisher) }
      end
    end

    failed "with transmission not owned by current publisher" do
      let(:record) { create(:transmission, :made_through_api) }
    end
  end

  describe_rule :complete?, stub_factories: false do
    let(:current_publisher) { create(:publisher) }

    succeed "without record" do
      let(:record) { Transmission }
    end

    succeed "with transmission owned by current publisher" do
      let(:record) { create(:transmission, :made_through_api, :with_reports, publisher: current_publisher) }

      failed "when already completed" do
        let(:record) { create(:transmission, :made_through_api, :completed, publisher: current_publisher) }
      end

      failed "without reports" do
        let(:record) { create(:transmission, :made_through_api, publisher: current_publisher) }
      end

      failed "with incomplete reports" do
        let(:record) { create(:transmission, :made_through_api, :with_incomplete_reports, publisher: current_publisher) }
      end
    end

    failed "with transmission not owned by current publisher" do
      let(:record) { create(:transmission, :made_through_api) }
    end
  end

  describe_rule :fill? do
    succeed "without record" do
      let(:record) { Transmission }
    end

    succeed "with transmission owned by current publisher" do
      let(:record) { build_stubbed(:transmission, :made_through_api, :with_reports, publisher: current_publisher) }

      failed "when transmission is already completed" do
        let(:record) { build_stubbed(:transmission, :made_through_api, :completed, publisher: current_publisher) }
      end
    end

    failed "with transmission not owned by current publisher" do
      let(:record) { build_stubbed(:transmission, :made_through_api) }
    end
  end

  describe "params scope" do
    subject(:params) { apply_params_scope(attributes) }

    let(:attributes) { { sandbox: true, not_included: true } }

    it do
      is_expected.to eq(sandbox: true)
    end
  end
end
