# frozen_string_literal: true

require "rails_helper"

RSpec.describe "OfficesController#create" do
  subject(:request) do
    post "/guichets", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { office: attributes }) }

  let!(:ddfip) { create(:ddfip) }

  let(:attributes) do
    {
      ddfip_id: ddfip.id,
      name:     Faker::Company.name,
      action:   Office::ACTIONS.sample
    }
  end

  context "when requesting HTML" do
    context "with valid attributes" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/guichets") }
      it { expect { request }.to change(Office, :count).by(1) }

      it "assigns expected attributes to the new record" do
        request
        expect(Office.last).to have_attributes(
          ddfip:  ddfip,
          name:   attributes[:name],
          action: attributes[:action]
        )
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          type:  "success",
          title: "Un nouveau guichet a été ajouté avec succés.",
          delay: 3000
        )
      end
    end

    context "with invalid attributes" do
      let(:attributes) { super().merge(name: "") }

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
      it { expect { request }.not_to change(Office, :count).from(0) }
    end

    context "with empty parameters", params: {} do
      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
      it { expect { request }.not_to change(Office, :count).from(0) }
    end

    context "with referrer header", headers: { "Referer" => "http://example.com/other/path" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/guichets") }
      it { expect(flash).to have_flash_notice }
    end

    context "with redirect parameter" do
      let(:params) { super().merge(redirect: "/other/path") }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/other/path") }
      it { expect(flash).to have_flash_notice }
    end
  end

  describe "when requesting JSON", as: :json do
    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:json) }
    it { expect(response).to have_empty_body }
    it { expect { request }.not_to change(Office, :count).from(0) }
  end
end
