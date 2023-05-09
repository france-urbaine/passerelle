# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Ddfips::UsersController#undiscard_all" do
  subject(:request) do
    patch "/ddfips/#{ddfip.id}/utilisateurs/undiscard", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { ids: ids }) }

  let!(:ddfip) { create(:ddfip) }
  let!(:users) { create_list(:user, 3, :discarded, organization: ddfip) }
  let!(:ids)   { users.take(2).map(&:id) }

  context "when requesting HTML" do
    context "with multiple ids" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/ddfips/#{ddfip.id}") }
      it { expect { request }.to change(User.discarded, :count).by(-2) }

      it "undiscards the selected users" do
        expect {
          request
          users.each(&:reload)
        }.to change(users[0], :discarded_at).to(nil)
          .and change(users[1], :discarded_at).to(nil)
          .and not_change(users[2], :discarded_at).from(be_present)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          type:  "cancel",
          title: "La suppression des utilisateurs sélectionnés a été annulée.",
          delay: 3000
        )
      end
    end

    context "with `all` ids", params: { ids: "all" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/ddfips/#{ddfip.id}") }
      it { expect(flash).to have_flash_notice }
      it { expect { request }.to change(User.discarded, :count).by(-3) }
    end

    context "with empty ids", params: { ids: [] } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/ddfips/#{ddfip.id}") }
      it { expect(flash).to have_flash_notice }
      it { expect { request }.not_to change(User.discarded, :count) }
    end

    context "with unknown ids", params: { ids: %w[1 2] } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/ddfips/#{ddfip.id}") }
      it { expect(flash).to have_flash_notice }
      it { expect { request }.not_to change(User.discarded, :count) }
    end

    context "with empty parameters", params: {} do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/ddfips/#{ddfip.id}") }
      it { expect(flash).to have_flash_notice }
      it { expect { request }.not_to change(User.discarded, :count) }
    end

    context "with user ids from other organizations" do
      let(:users) { create_list(:user, 3, :discarded) }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/ddfips/#{ddfip.id}") }
      it { expect(flash).to have_flash_notice }
      it { expect { request }.not_to change(User.discarded, :count) }
    end

    context "when DDFIP is discarded" do
      let(:ddfip) { create(:ddfip, :discarded) }

      it { expect(response).to have_http_status(:gone) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when DDFIP is missing" do
      let(:ddfip) { DDFIP.new(id: Faker::Internet.uuid) }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "with referrer header", headers: { "Referer" => "http://www.example.com/parent/path" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("http://www.example.com/parent/path") }
      it { expect(flash).to have_flash_notice }
    end

    context "with redirect parameter", params: { redirect: "/other/path" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/other/path") }
      it { expect(flash).to have_flash_notice }
    end
  end

  describe "when requesting JSON", as: :json do
    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:json) }
    it { expect(response).to have_empty_body }
    it { expect { request }.not_to change(User.discarded, :count) }
  end
end
