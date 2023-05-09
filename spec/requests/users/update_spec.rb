# frozen_string_literal: true

require "rails_helper"

RSpec.describe "UsersController#update" do
  subject(:request) do
    patch "/utilisateurs/#{user.id}", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { user: updated_attributes }) }

  let!(:user) { create(:user, first_name: "Guillaume", last_name: "Debailly") }

  let(:updated_attributes) do
    { first_name: "Paul", last_name: "Lefebvre" }
  end

  context "when requesting HTML" do
    context "with valid parameters" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/utilisateurs") }

      it "updates the user" do
        expect {
          request
          user.reload
        }.to change(user, :updated_at)
          .and change(user, :name).to("Paul Lefebvre")
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          type:  "success",
          title: "Les modifications ont été enregistrées avec succés.",
          delay: 3000
        )
      end
    end

    context "with invalid attributes", params: { user: { email: "" } } do
      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
      it { expect { request and user.reload }.not_to change(user, :updated_at) }
      it { expect { request and user.reload }.not_to change(user, :name) }
    end

    context "with empty parameters", params: {} do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/utilisateurs") }
      it { expect { request and user.reload }.not_to change(user, :updated_at) }
    end

    context "when the user is discarded" do
      let(:user) { create(:user, :discarded) }

      it { expect(response).to have_http_status(:gone) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when the user is missing" do
      let(:user) { User.new(id: Faker::Internet.uuid) }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "with referrer header", headers: { "Referer" => "http://example.com/parent/path" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/utilisateurs") }
    end

    context "with redirect parameter" do
      let(:params) do
        super().merge(redirect: "/other/path")
      end

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/other/path") }
    end
  end

  describe "when requesting JSON", as: :json do
    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:json) }
    it { expect(response).to have_empty_body }
    it { expect { request and user.reload }.not_to change(user, :updated_at) }
    it { expect { request and user.reload }.not_to change(user, :name) }
  end
end