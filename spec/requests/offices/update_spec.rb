# frozen_string_literal: true

require "rails_helper"

RSpec.describe "OfficesController#update" do
  subject(:request) do
    patch "/guichets/#{office.id}", as:, params:
  end

  let(:as)     { |e| e.metadata[:as] }
  let(:params) { { office: updated_attributes } }

  let!(:office) { create(:office, name: "Fiscalité & Territoire") }

  let(:updated_attributes) do
    { name: "Solutions & Territoire" }
  end

  context "when requesting HTML" do
    context "with valid parameters" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/guichets") }

      it "updates the office" do
        expect {
          request
          office.reload
        }.to change(office, :updated_at)
          .and change(office, :name).to("Solutions & Territoire")
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          type:  "success",
          title: "Les modifications ont été enregistrées avec succés.",
          delay: 3000
        )
      end
    end

    context "with invalid parameters" do
      let(:updated_attributes) do
        super().merge(name: "")
      end

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
      it { expect { request and office.reload }.not_to change(office, :updated_at) }
      it { expect { request and office.reload }.not_to change(office, :name) }
    end

    context "with missing office parameters" do
      let(:params) { {} }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/guichets") }
      it { expect { request and office.reload }.not_to change(office, :updated_at) }
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
    it { expect { request and office.reload }.not_to change(office, :updated_at) }
    it { expect { request and office.reload }.not_to change(office, :name) }
  end
end
