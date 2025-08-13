# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::UsersController#create" do
  subject(:request) do
    post "/admin/utilisateurs", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { user: attributes }) }

  let(:organization) { create(%i[publisher collectivity ddfip].sample) }

  let(:attributes) do
    {
      organization_type: organization.class.name,
      organization_id:   organization.id,
      first_name:        Faker::Name.first_name,
      last_name:         Faker::Name.last_name,
      email:             Faker::Internet.email
    }
  end

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to DDFIP admin"
    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to publisher admin"
    it_behaves_like "it denies access to collectivity user"
    it_behaves_like "it denies access to collectivity admin"

    it_behaves_like "it allows access to super admin"
  end

  describe "responses" do
    before { sign_in_as(:super_admin) }

    context "with valid attributes" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/utilisateurs") }
      it { expect { request }.to change(User, :count).by(1) }

      it "assigns expected attributes to the new record" do
        request
        expect(User.last).to have_attributes(
          organization: organization,
          first_name:   attributes[:first_name],
          last_name:    attributes[:last_name],
          email:        attributes[:email]
        )
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          scheme: "success",
          header: "Un nouvel utilisateur a été ajouté avec succés.",
          body:   "Un mail d'invitation a été envoyé avec les instructions nécessaires pour valider le compte.",
          delay:   3000
        )
      end

      it "delivers confirmation instructions" do
        expect { request }
          .to have_sent_emails.by(1)
          .and have_sent_email.with_subject("Votre inscription sur Passerelle")
      end
    end

    context "with invalid attributes" do
      let(:attributes) { super().merge(email: "") }

      it { expect(response).to have_http_status(:unprocessable_content) }
      it { expect(response).to have_media_type(:html) }
      it { expect(response).to have_html_body }
      it { expect { request }.not_to change(User, :count).from(1) }
    end

    context "when using organization_id attribute" do
      let(:attributes) do
        super().merge(
          organization_type: organization_type,
          organization_id:   organization_id
        )
      end

      context "with a Publisher as organization" do
        let!(:publisher)        { create(:publisher) }
        let(:organization_type) { "Publisher" }
        let(:organization_id)   { publisher.id }

        it "assigns the expected organization to the new record" do
          request
          expect(User.last.organization).to eq(publisher)
        end
      end

      context "with a DDFIP as organization" do
        let!(:ddfip)            { create(:ddfip) }
        let(:organization_type) { "DDFIP" }
        let(:organization_id)   { ddfip.id }

        it "assigns the expected organization to the new record" do
          request
          expect(User.last.organization).to eq(ddfip)
        end
      end

      context "with a Collectivity as organization" do
        let!(:collectivity)     { create(:collectivity) }
        let(:organization_type) { "Collectivity" }
        let(:organization_id)   { collectivity.id }

        it "assigns the expected organization to the new record" do
          request
          expect(User.last.organization).to eq(collectivity)
        end
      end
    end

    context "when using organization_name attribute" do
      let(:attributes) do
        super()
          .except(:organization_id)
          .merge(
            organization_type: organization_type,
            organization_name: organization_name
          )
      end

      context "with a Publisher as organization" do
        let!(:publisher)        { create(:publisher) }
        let(:organization_type) { "Publisher" }
        let(:organization_name) { publisher.name }

        it "assigns the expected organization to the new record" do
          request
          expect(User.last.organization).to eq(publisher)
        end
      end

      context "with a DDFIP as organization" do
        let!(:ddfip)            { create(:ddfip) }
        let(:organization_type) { "DDFIP" }
        let(:organization_name) { ddfip.name }

        it "assigns the expected organization to the new record" do
          request
          expect(User.last.organization).to eq(ddfip)
        end
      end

      context "with a Collectivity as organization" do
        let!(:collectivity)     { create(:collectivity) }
        let(:organization_type) { "Collectivity" }
        let(:organization_name) { collectivity.name }

        it "assigns the expected organization to the new record" do
          request
          expect(User.last.organization).to eq(collectivity)
        end
      end

      context "with an invalid organization_name" do
        let(:organization_type) { "Publisher" }
        let(:organization_name) { "dsfhqsfgjhqs" }

        it { expect(response).to have_http_status(:unprocessable_content) }
        it { expect { request }.not_to change(User, :count).from(1) }
      end
    end

    context "when using organization_data attribute in JSON" do
      let(:attributes) do
        super()
          .except(:organization_id)
          .merge(
            organization_data: {
              type: organization_type,
              id:   organization_id
            }.to_json
          )
      end

      context "with a Publisher as organization" do
        let!(:publisher)        { create(:publisher) }
        let(:organization_type) { "Publisher" }
        let(:organization_id)   { publisher.id }

        it "assigns the expected organization to the new record" do
          request
          expect(User.last.organization).to eq(publisher)
        end
      end

      context "with a DDFIP as organization" do
        let!(:ddfip)            { create(:ddfip) }
        let(:organization_type) { "DDFIP" }
        let(:organization_id)   { ddfip.id }

        it "assigns the expected organization to the new record" do
          request
          expect(User.last.organization).to eq(ddfip)
        end
      end

      context "with a Collectivity as organization" do
        let!(:collectivity)     { create(:collectivity) }
        let(:organization_type) { "Collectivity" }
        let(:organization_id)   { collectivity.id }

        it "assigns the expected organization to the new record" do
          request
          expect(User.last.organization).to eq(collectivity)
        end
      end

      context "with an invalid organization ID" do
        let(:organization_type) { "Publisher" }
        let(:organization_id)   { "1234" }

        it { expect(response).to have_http_status(:unprocessable_content) }
        it { expect { request }.not_to change(User, :count).from(1) }
      end
    end

    context "when using office_users_attributes" do
      let(:organization) { create(:ddfip) }
      let(:offices)      { create_list(:office, 2, ddfip: organization) }

      let(:attributes) do
        super().merge(office_users_attributes: offices.map do |office|
          { office_id: office.id }
        end)
      end

      it "assigns the offices to the new user" do
        request
        expect(User.last.offices).to have(2).offices.and include(*offices)
      end
    end

    context "with empty parameters", params: {} do
      it { expect(response).to have_http_status(:unprocessable_content) }
      it { expect(response).to have_media_type(:html) }
      it { expect(response).to have_html_body }
      it { expect { request }.not_to change(User, :count).from(1) }
    end

    context "with referrer header", headers: { "Referer" => "http://example.com/other/path" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/utilisateurs") }
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
