# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::ReportPolicy, stub_factories: false do
  let!(:publisher) { create(:publisher) }
  let(:context) { { user: nil, publisher: publisher } }

  before { create(:collectivity, publisher: publisher) }

  describe_rule :index? do
    succeed "always"
  end

  describe_rule :create? do
    succeed "always"
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
