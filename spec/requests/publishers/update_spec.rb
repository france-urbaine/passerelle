# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PublishersController#update" do
  subject(:request) do
    patch "/editeurs/#{publisher.id}", as:, params:
  end

  let(:as)     { |e| e.metadata[:as] }
  let(:params) { { publisher: updated_attributes } }

  let!(:publisher) { create(:publisher, name: "Fiscalité & Territoire") }

  let(:updated_attributes) do
    { name: "Solutions & Territoire" }
  end

  context "when requesting HTML" do
    context "with valid parameters" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/editeurs") }

      it "updates the publisher" do
        expect {
          request
          publisher.reload
        }.to change(publisher, :updated_at)
          .and change(publisher, :name).to("Solutions & Territoire")
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          type:  "success",
          title: "Les modifications ont été enregistrées avec succés.",
          delay: 3000
        )
      end
    end

    context "when the publisher is discarded" do
      let(:publisher) { create(:publisher, :discarded) }

      it { expect(response).to have_http_status(:gone) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when the publisher is missing" do
      let(:publisher) { Publisher.new(id: Faker::Internet.uuid) }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "with invalid parameters" do
      let(:updated_attributes) do
        super().merge(name: "")
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
      it { expect { request and publisher.reload }.not_to change(publisher, :updated_at) }
      it { expect { request and publisher.reload }.not_to change(publisher, :name) }
    end

    context "with missing publisher parameters" do
      let(:params) { {} }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/editeurs") }
      it { expect { request and publisher.reload }.not_to change(publisher, :updated_at) }
    end

    context "with redirect parameter" do
      let(:params) do
        super().merge(redirect: "/editeur/12345")
      end

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/editeur/12345") }
    end
  end

  describe "when requesting JSON", as: :json do
    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:json) }
    it { expect(response).to have_empty_body }
    it { expect { request and publisher.reload }.not_to change(publisher, :updated_at) }
    it { expect { request and publisher.reload }.not_to change(publisher, :name) }
  end
end
