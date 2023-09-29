# frozen_string_literal: true

require "rails_helper"

RSpec.describe "TransmissionsController#complete" do
  subject(:request) do
    post "/transmissions/complete", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }

  let(:transmission) { create(:transmission, :made_through_web_ui) }
  let(:reports) do
    [
      create(:report, :completed, :evaluation_local_habitation, transmission: transmission, collectivity: transmission.collectivity),
      create(:report, :completed, :evaluation_local_habitation, transmission: transmission, collectivity: transmission.collectivity),
      create(:report, :completed, :creation_local_habitation,   transmission: transmission, collectivity: transmission.collectivity)
    ]
  end

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to publisher admin"
    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to DDFIP admin"
    it_behaves_like "it allows access to collectivity user"
    it_behaves_like "it allows access to collectivity admin"
  end

  describe "response" do
    before do
      sign_in transmission.user
      reports.each { |report| report.update(package: nil, reference: nil) }
    end

    it "creates packages, assigns reports and completes transmission" do
      expect {
        request
        transmission.reload
        reports.each(&:reload)
      }
        .to  change(Package, :count).by(2)
        .and change(reports[0], :reference).to(be_present)
        .and change(reports[1], :reference).to(be_present)
        .and change(reports[2], :reference).to(be_present)
        .and change(transmission, :completed_at).to(be_present)
    end
  end
end
