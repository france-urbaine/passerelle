# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Offices::UsersController#destroy_all" do
  subject(:request) do
    delete "/guichets/#{office.id}/utilisateurs", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { ids: ids }) }

  let!(:ddfip)  { create(:ddfip) }
  let!(:office) { create(:office, ddfip: ddfip) }
  let!(:users)  { create_list(:user, 3, organization: ddfip, offices: [office]) }
  let!(:ids)    { users.take(2).map(&:id) }

  context "when requesting HTML" do
    context "with multiple ids" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/guichets/#{office.id}") }

      it "removes the selected users from the office" do
        expect {
          request
          office.users.reload
        }.to change { office.users.count }.from(3).to(1)
      end

      it "doesn't discard the selected users" do
        expect {
          request
          users.each(&:reload)
        }.to not_change(users[0], :discarded_at).from(nil)
          .and not_change(users[1], :discarded_at).from(nil)
          .and not_change(users[2], :discarded_at).from(nil)
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          type:        "success",
          title:       "Les utilisateurs sélectionnés ont été exclus du guichet.",
          delay:        10_000
        )
      end

      it "doens't set a flash action to cancel" do
        expect(flash).not_to have_flash_actions
      end
    end

    context "with `all` ids", params: { ids: "all" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/guichets/#{office.id}") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).not_to have_flash_actions }
      it { expect { request }.to change { office.users.count }.by(-3) }
      it { expect { request }.not_to change(User.discarded, :count) }
    end

    context "with empty ids", params: { ids: [] } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/guichets/#{office.id}") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).not_to have_flash_actions }
      it { expect { request }.not_to change { office.users.count } }
      it { expect { request }.not_to change(User.discarded, :count) }
    end

    context "with unknown ids", params: { ids: %w[1 2] } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/guichets/#{office.id}") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).not_to have_flash_actions }
      it { expect { request }.not_to change { office.users.count } }
      it { expect { request }.not_to change(User.discarded, :count) }
    end

    context "with empty parameters", params: {} do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/guichets/#{office.id}") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).not_to have_flash_actions }
      it { expect { request }.not_to change { office.users.count } }
      it { expect { request }.not_to change(User.discarded, :count) }
    end

    context "with user ids not belonging to the office" do
      let(:users) { create_list(:user, 3, :discarded, organization: ddfip) }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/guichets/#{office.id}") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).not_to have_flash_actions }
      it { expect { request }.not_to change { office.users.count } }
      it { expect { request }.not_to change(User.discarded, :count) }
    end

    context "with user ids from other organizations" do
      let(:users) { create_list(:user, 3) }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/guichets/#{office.id}") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).not_to have_flash_actions }
      it { expect { request }.not_to change { office.users.count } }
      it { expect { request }.not_to change(User.discarded, :count) }
    end

    context "when the DDFIP is discarded" do
      let(:ddfip) { create(:ddfip, :discarded) }

      it { expect(response).to have_http_status(:gone) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when the office is discarded" do
      let(:office) { create(:office, :discarded, ddfip: ddfip) }

      it { expect(response).to have_http_status(:gone) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when the office is missing" do
      let(:office) { Office.new(id: Faker::Internet.uuid) }
      let(:users)  { create_list(:user, 3, organization: ddfip) }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "with referrer header", headers: { "Referer" => "http://example.com/parent/path" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/guichets/#{office.id}") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).not_to have_flash_actions }
    end

    context "with redirect parameter", params: { redirect: "/other/path" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/other/path") }
      it { expect(flash).to have_flash_notice }
      it { expect(flash).not_to have_flash_actions }
    end
  end

  describe "when requesting JSON", as: :json do
    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:json) }
    it { expect(response).to have_empty_body }
    it { expect { request }.not_to change(User.discarded, :count) }
  end
end
