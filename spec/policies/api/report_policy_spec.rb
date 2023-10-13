# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::ReportPolicy, type: :policy do
  let(:current_publisher) { build_stubbed(:publisher) }
  let(:context)           { { user: nil, publisher: current_publisher } }

  describe_rule :index? do
    succeed "always"
  end

  describe_rule :create? do
    succeed "always"
  end

  describe_rule :attach? do
    context "without record" do
      let(:record) { Report }

      succeed "always"
    end

    context "with record" do
      let(:record) { build_stubbed(:report, :made_through_api, publisher: current_publisher) }

      failed "when record has package" do
        let(:record) { build_stubbed(:report, :transmitted, publisher: current_publisher) }
      end
      failed "when record publisher is not current_publisher" do
        before { record.publisher = build(:publisher) }
      end
      succeed "with all requirements"
    end
  end

  describe "params scope" do
    subject(:params) { apply_params_scope(attributes) }

    let(:attributes) do
      {
        form_type:    "evaluation_local_habitation",
        priority:     "high",
        code_insee:   "12345",
        date_constat: "2019-01-01",
        enjeu:        "enjeu",
        observations: "observations",
        anomalies:    %w[anomalie1 anomalie2],
        sibling_id:   "123456789"
      }
    end

    it do
      is_expected.to include(
        form_type:       attributes[:form_type],
        priority:        attributes[:priority],
        code_insee:      attributes[:code_insee],
        date_constat:    attributes[:date_constat],
        enjeu:           attributes[:enjeu],
        observations:    attributes[:observations],
        anomalies:       attributes[:anomalies]
      ).and not_include(:sibling_id)
    end
  end
end
