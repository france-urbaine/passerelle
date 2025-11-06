# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Reports::ConfirmationsController#update_all" do
  subject(:request) do
    patch "/signalements/confirm/", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { ids: ids }) }

  let!(:ddfip) { create(:ddfip) }
  let!(:reports) do
    [
      create(:report, :resolved_as_applicable, ddfip:),
      create(:report, :resolved_as_inapplicable, ddfip:),
      create(:report, :resolved_as_applicable, ddfip:),
      create(:report, :approved_by_ddfip, ddfip:),
      create(:report, :resolved_as_applicable)
    ]
  end

  let!(:ids) { reports.take(2).map(&:id) }

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it allows access to DDFIP admin"
    it_behaves_like "it allows access to DDFIP form admin"

    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to publisher admin"
    it_behaves_like "it denies access to collectivity user"
    it_behaves_like "it denies access to collectivity admin"
  end

  describe "responses" do
    before { sign_in_as(:organization_admin, organization: ddfip) }

    context "with multiple ids" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/signalements") }
      it { expect { request }.to change(Report.approved, :count).by(1) }
      it { expect { request }.to change(Report.canceled, :count).by(1) }

      it "confirms selected reports" do
        expect {
          request
          reports.each(&:reload)
        }
          .to  change(reports[0], :state).to("approved")
          .and change(reports[1], :state).to("canceled")
          .and not_change(reports[2], :state)
          .and not_change(reports[3], :state)
          .and not_change(reports[4], :state)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          scheme: "success",
          header: "Les signalements sélectionnés ont été transmis à leur collectivités respectives.",
          delay:  3000
        )
      end
    end

    context "with only ids of already confirmed reports" do
      let(:ids) { reports[3, 1].map(&:id) }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/signalements") }
      it { expect(flash).to have_flash_notice }
      it { expect { request }.to not_change(Report.approved, :count) }
      it { expect { request }.to not_change(Report.canceled, :count) }
    end

    context "with only one id" do
      let(:ids) { reports.take(1).map(&:id) }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/signalements") }
      it { expect(flash).to have_flash_notice }
      it { expect { request }.to change(Report.approved, :count).by(1) }
      it { expect { request }.to not_change(Report.canceled, :count) }
    end

    context "with `all` ids", params: { ids: "all" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/signalements") }
      it { expect(flash).to have_flash_notice }
      it { expect { request }.to change(Report.approved, :count).by(2) }
      it { expect { request }.to change(Report.canceled, :count).by(1) }
    end

    context "with empty ids", params: { ids: [] } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/signalements") }
      it { expect(flash).to have_flash_notice }
      it { expect { request }.not_to change(Report.approved, :count) }
      it { expect { request }.not_to change(Report.canceled, :count) }
    end

    context "with unknown ids", params: { ids: %w[1 2] } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/signalements") }
      it { expect(flash).to have_flash_notice }
      it { expect { request }.not_to change(Report.approved, :count) }
      it { expect { request }.not_to change(Report.canceled, :count) }
    end

    context "with empty parameters", params: {} do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/signalements") }
      it { expect(flash).to have_flash_notice }
      it { expect { request }.not_to change(Report.approved, :count) }
      it { expect { request }.not_to change(Report.canceled, :count) }
    end

    context "with referrer header", headers: { "Referer" => "http://example.com/other/path" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/signalements") }
    end

    context "with redirect parameter" do
      let(:params) { super().merge(redirect: "/other/path") }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/other/path") }
    end
  end
end
