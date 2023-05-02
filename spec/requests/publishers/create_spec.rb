# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PublishersController#create" do
  subject(:request) do
    post "/editeurs", as:, params:
  end

  let(:as)     { |e| e.metadata[:as] }
  let(:params) { { publisher: attributes } }

  let(:attributes) do
    {
      name:  Faker::Company.name,
      siren: Faker::Company.french_siren_number
    }
  end

  context "when requesting HTML" do
    context "with valid parameters" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/editeurs") }
      it { expect { request }.to change(Publisher, :count).by(1) }

      it "assigns expected attributes to the new record" do
        request
        expect(Publisher.last).to have_attributes(
          name:  attributes[:name],
          siren: attributes[:siren]
        )
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          type:  "success",
          title: "Un nouvel éditeur a été ajouté avec succés.",
          delay: 3000
        )
      end
    end

    context "with invalid parameters" do
      let(:attributes) do
        super().merge(siren: "")
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
      it { expect { request }.not_to change(Publisher, :count).from(0) }
    end

    context "with missing publisher parameters" do
      let(:params) { {} }

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
      it { expect { request }.not_to change(Publisher, :count).from(0) }
    end

    context "with redirect parameter" do
      let(:params) do
        super().merge(redirect: "/")
      end

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/") }
    end
  end

  describe "when requesting JSON", as: :json do
    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:json) }
    it { expect(response).to have_empty_body }
    it { expect { request }.not_to change(Publisher, :count).from(0) }
  end
end
