# frozen_string_literal: true

require "rails_helper"

RSpec.describe "TransmissionsController#create" do
  subject(:request) do
    post "/transmissions", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { ids: ids }) }

  let!(:transmission) { create(:transmission, :made_through_web_ui) }
  let!(:report)       { create(:report, :completed, collectivity: transmission.collectivity) }
  let!(:reports) do
    [
      create(:report, :completed,   collectivity: transmission.collectivity),
      create(:report, :completed,   collectivity: transmission.collectivity),
      create(:report, :transmitted, collectivity: transmission.collectivity)
    ]
  end

  let!(:ids) { [] }

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

  describe "responses" do
    context "when signed in as a collectivity user" do
      before { sign_in transmission.user }

      context "when adding a transmissible report" do
        let(:ids) { [report.id] }

        before do
          report.update(package: nil, reference: nil)
        end

        it { expect{ request }.to change(transmission.reports, :count).to(1) }
      end

      context "when adding an intransmissible report" do
        let(:ids) { [report.id] }

        it { expect{ request }.not_to change(transmission.reports, :count) }
      end

      context "when adding multiple reports" do
        let(:ids) { reports.map(&:id) }

        before do
          reports[0].update(package: nil, reference: nil)
          reports[1].update(package: nil, reference: nil)
        end

        it "only adds transmissibles reports" do
          expect{
            request
            reports.each(&:reload)
          }
            .to change(transmission.reports, :count).to(2)
            .and change(reports[0], :transmission_id).to(transmission.id)
            .and change(reports[1], :transmission_id).to(transmission.id)
            .and not_change(reports[2], :transmission_id)
        end
      end
    end
  end
end
