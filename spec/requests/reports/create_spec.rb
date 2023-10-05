# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ReportsController#new" do
  subject(:request) do
    post "/signalements", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { report: attributes }) }

  let(:attributes) do
    { form_type: "evaluation_local_habitation" }
  end

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it allows access to collectivity user"
    it_behaves_like "it allows access to collectivity admin"

    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to publisher admin"
    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to DDFIP admin"
  end

  describe "responses" do
    before { sign_in_as(:collectivity) }

    it { expect(response).to have_http_status(:see_other) }
    it { expect(response).to redirect_to(%r{/signalements/[0-9a-f\-]{36}$}) }
    it { expect { request }.to change(Report, :count).by(1) }

    it "assigns expected attributes to the new record" do
      request
      expect(Report.last).to have_attributes(
        form_type:        attributes[:form_type],
        collectivity_id:  current_user.organization_id,
        publisher_id:     nil
      )
    end
  end
end
