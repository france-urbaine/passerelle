# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PublishersController#undiscard_all" do
  subject(:request) do
    patch "/editeurs/undiscard", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { ids: ids }) }

  let!(:publishers) do
    [
      create(:publisher, :discarded),
      create(:publisher, :discarded),
      create(:publisher, :discarded),
      create(:publisher)
    ]
  end

  let!(:ids) { publishers.take(2).map(&:id) }

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to publisher admin"
    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to DDFIP admin"
    it_behaves_like "it denies access to collectivity user"
    it_behaves_like "it denies access to collectivity admin"
    it_behaves_like "it allows access to super admin"
  end

  describe "responses" do
    before { sign_in_as(:super_admin) }

    context "with multiple ids" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/editeurs") }
      it { expect { request }.to change(Publisher.discarded, :count).by(-2) }

      it "undiscards the selected publishers" do
        expect {
          request
          publishers.each(&:reload)
        }.to change(publishers[0], :discarded_at).to(nil)
          .and change(publishers[1], :discarded_at).to(nil)
          .and not_change(publishers[2], :discarded_at).from(be_present)
          .and not_change(publishers[3], :discarded_at).from(nil)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          type:  "cancel",
          title: "La suppression des éditeurs sélectionnés a été annulée.",
          delay: 3000
        )
      end
    end

    context "with ids from already undiscarded publishers" do
      let(:ids) { publishers.last(1).map(&:id) }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/editeurs") }
      it { expect(flash).to have_flash_notice }
      it { expect { request }.not_to change(Publisher.discarded, :count) }
    end

    context "with only one id" do
      let(:ids) { publishers.take(1).map(&:id) }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/editeurs") }
      it { expect(flash).to have_flash_notice }
      it { expect { request }.to change(Publisher.discarded, :count).by(-1) }
    end

    context "with `all` ids", params: { ids: "all" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/editeurs") }
      it { expect { request }.to change(Publisher.discarded, :count).by(-3) }
    end

    context "with empty ids", params: { ids: [] } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/editeurs") }
      it { expect { request }.not_to change(Publisher.discarded, :count) }
    end

    context "with unknown ids", params: { ids: %w[1 2] } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/editeurs") }
      it { expect { request }.not_to change(Publisher.discarded, :count) }
    end

    context "with empty parameters", params: {} do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/editeurs") }
      it { expect(flash).to have_flash_notice }
      it { expect { request }.not_to change(Publisher.discarded, :count) }
    end

    context "with referrer header", headers: { "Referer" => "http://www.example.com/other/path" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("http://www.example.com/other/path") }
      it { expect(flash).to have_flash_notice }
    end

    context "with redirect parameter" do
      let(:params) { super().merge(redirect: "/other/path") }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/other/path") }
      it { expect(flash).to have_flash_notice }
    end
  end
end
