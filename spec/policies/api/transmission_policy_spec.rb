# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::TransmissionPolicy, stub_factories: false do
  let!(:publisher) { create(:publisher) }
  let!(:collectivity) { create(:collectivity, publisher: publisher) }
  let(:context) { { user: nil, publisher: publisher } }

  describe_rule :create? do
    context "without record" do
      let(:record) { Transmission }

      succeed "when publisher is present"
    end

    context "with transmission" do
      let(:record) { build_stubbed(:transmission, :made_through_api, publisher: publisher) }

      failed "without collectivity within publisher"
      succeed "with collectivity within publisher" do
        before { record.collectivity = publisher.collectivities.first }
      end
    end
  end

  describe_rule :complete? do
    context "without record" do
      let(:record) { Transmission }

      succeed "when publisher is present"
    end

    context "with transmission" do
      let(:record) { create(:transmission, :made_through_api, publisher: publisher, collectivity: collectivity) }
      let!(:report) { create(:report, :completed, collectivity: collectivity, transmission: record) }

      failed "without collectivity within publisher" do
        before { collectivity.update_column(:publisher_id, nil) }
      end
      failed "without reports linked to transmission" do
        before { report.update_column(:transmission_id, nil) }
      end
      failed "with uncompleted reports" do
        before { report.update_column(:completed_at, nil) }
      end
      succeed "with all requirements"
    end
  end

  describe_rule :fill? do
    let(:record) { build_stubbed(:transmission, :made_through_api, publisher: publisher, collectivity: collectivity) }

    failed "with completed transmission" do
      before { record.completed_at = DateTime.current }
    end

    failed "with collectivity not linked to publisher" do
      before { collectivity.update_column(:publisher_id, nil) }
    end
    succeed "with all requirements"
  end

  describe "params scope" do
    subject(:params) { apply_params_scope(attributes) }

    let(:attributes) do
      {
        sandbox:         true,
        collectivity_id: collectivity_id
      }
    end
    let(:collectivity_id) { "123456789" }

    it "ignore collectivity_id when collectivity attribute do not belongs to publisher" do
      is_expected.to include(
        sandbox: attributes[:sandbox]
      ).and not_include(:collectivity_id)
    end

    context "with collectivity_id" do
      let(:collectivity_id) { collectivity.id }

      it do
        is_expected.to include(
          sandbox: attributes[:sandbox],
          collectivity_id: attributes[:collectivity_id]
        )
      end
    end
  end
end
