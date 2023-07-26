# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Organization::Collectivities::UsersController#create" do
  subject(:request) do
    post "/organisation/collectivites/#{collectivity.id}/utilisateurs", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { user: attributes }) }

  let(:publisher)     { create(:publisher) }
  let!(:collectivity) { create(:collectivity, publisher: publisher) }
  let(:attributes) do
    {
      first_name: Faker::Name.first_name,
      last_name:  Faker::Name.last_name,
      email:      Faker::Internet.email
    }
  end

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to DDFIP admin"
    it_behaves_like "it denies access to DDFIP super admin"
    it_behaves_like "it denies access to collectivity user"
    it_behaves_like "it denies access to collectivity admin"
    it_behaves_like "it denies access to collectivity super admin"

    it_behaves_like "it responds with not found to publisher user"
    it_behaves_like "it responds with not found to publisher admin"
    it_behaves_like "it responds with not found to publisher super admin"

    context "when the collectivity is the organization of the current user" do
      let(:collectivity) { current_user.organization }

      it_behaves_like "it denies access to collectivity user"
      it_behaves_like "it denies access to collectivity admin"
      it_behaves_like "it denies access to collectivity super admin"
    end

    context "when the collectivity is owned by the current user's publisher organization" do
      let(:publisher) { current_user.organization }

      it_behaves_like "it allows access to publisher user"
      it_behaves_like "it allows access to publisher admin"
      it_behaves_like "it allows access to publisher super admin"
    end
  end

  describe "responses" do
    before { sign_in_as(:organization_admin, organization: publisher) }

    context "with valid attributes" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/collectivites/#{collectivity.id}") }
      it { expect { request }.to change(User, :count).by(1) }

      it "assigns expected attributes to the new record" do
        request
        expect(User.last).to have_attributes(
          organization: collectivity,
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
          .and have_sent_email.with_subject("Votre inscription sur FiscaHub")
      end
    end

    context "with invalid attributes" do
      let(:attributes) { super().merge(email: "") }

      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
      it { expect { request }.not_to change(User, :count).from(1) }
    end

    context "when using organization_id attribute" do
      let(:another_collectivity) { create(:collectivity, publisher: publisher) }
      let(:attributes) do
        super().merge(
          organization_type: another_collectivity.class.name,
          organization_id:   another_collectivity.id
        )
      end

      it "ignores the attributes to assign the publisher in the URL" do
        request
        expect(User.last.organization).to eq(collectivity)
      end
    end

    context "when using organization_name attribute" do
      let(:another_collectivity) { create(:collectivity, publisher: publisher) }
      let(:attributes) do
        super()
          .except(:organization_id)
          .merge(
            organization_type: another_collectivity.class.name,
            organization_name: another_collectivity.name
          )
      end

      it "ignores the attributes to assign the publisher in the URL" do
        request
        expect(User.last.organization).to eq(collectivity)
      end
    end

    context "when using organization_data attribute in JSON" do
      let(:another_collectivity) { create(:collectivity, publisher: publisher) }
      let(:attributes) do
        super()
          .except(:organization_id)
          .merge(
            organization_data: {
              type: another_collectivity.class.name,
              id:   another_collectivity.id
            }.to_json
          )
      end

      it "ignores the attributes to assign the publisher in the URL" do
        request
        expect(User.last.organization).to eq(collectivity)
      end
    end

    context "when using office_ids" do
      let(:offices) { create_list(:office, 3) }
      let(:attributes) do
        super().merge(office_ids: offices[0..1].map(&:id))
      end

      it "ignores the offices attributes" do
        request
        expect(User.last.offices).to be_empty
      end
    end

    context "with empty parameters", params: {} do
      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
      it { expect { request }.not_to change(User, :count).from(1) }
    end

    context "with referrer header", headers: { "Referer" => "http://example.com/other/path" } do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/collectivites/#{collectivity.id}") }
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
