# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Offices::UsersController#create" do
  subject(:request) do
    post "/guichets/#{office.id}/utilisateurs", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { user: attributes }) }

  let!(:ddfip)  { create(:ddfip) }
  let!(:office) { create(:office, ddfip: ddfip) }

  let(:attributes) do
    {
      first_name: Faker::Name.first_name,
      last_name:  Faker::Name.last_name,
      email:      Faker::Internet.email,
      office_ids: [office.id]
    }
  end

  context "when requesting HTML" do
    context "with valid parameters" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/guichets/#{office.id}") }
      it { expect { request }.to change(User, :count).by(1) }

      it "assigns expected attributes to the new record" do
        request
        expect(User.last).to have_attributes(
          organization: ddfip,
          office_ids:   attributes[:office_ids],
          first_name:   attributes[:first_name],
          last_name:    attributes[:last_name],
          email:        attributes[:email]
        )
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          type:        "success",
          title:       "Un nouvel utilisateur a été ajouté avec succés.",
          description: "Un mail d'invitation a été envoyé avec les instructions nécessaires pour valider le compte.",
          delay:       3000
        )
      end

      it "sent instructions to confirm" do
        expect { request }
          .to have_sent_emails.by(1)
          .and have_sent_email.with_subject("Instructions de confirmation")
      end
    end

    context "with invalid attributes" do
      let(:attributes) { super().merge(email: "") }

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
      it { expect { request }.not_to change(User, :count).from(0) }
    end

    context "when using organization_id parameter" do
      let(:another_ddfip) { create(:ddfip) }

      let(:attributes) do
        super().merge(
          organization_type: "DDFIP",
          organization_id:   another_ddfip.id
        )
      end

      it "assigns the DDFIP from the office in the URL" do
        request
        expect(User.last.organization).to eq(ddfip)
      end
    end

    context "with empty parameters", params: {} do
      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
      it { expect { request }.not_to change(User, :count).from(0) }
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

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "with referrer header", headers: { "Referer" => "http://example.com/parent/path" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/guichets/#{office.id}") }
    end

    context "with redirect parameter" do
      let(:params) { super().merge(redirect: "/other/path") }

      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/other/path") }
    end
  end

  describe "when requesting JSON", as: :json do
    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:json) }
    it { expect(response).to have_empty_body }
    it { expect { request }.not_to change(User, :count).from(0) }
  end
end
