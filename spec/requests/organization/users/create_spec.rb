# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Organization::UsersController#create" do
  subject(:request) do
    post "/organisation/utilisateurs", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { user: attributes }) }

  let(:organization) { create(%i[publisher collectivity ddfip].sample) }

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

    it_behaves_like "it denies access to super admin"
    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to collectivity user"

    it_behaves_like "it allows access to DDFIP admin"
    it_behaves_like "it allows access to publisher admin"
    it_behaves_like "it allows access to collectivity admin"
  end

  describe "responses" do
    before { sign_in_as(:organization_admin, organization: organization) }

    let(:organization) do
      create(%i[publisher collectivity ddfip].sample)
    end

    context "with valid attributes" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/organisation/utilisateurs") }
      it { expect { request }.to change(User, :count).by(1) }

      it "assigns expected attributes to the new record" do
        request
        expect(User.last).to have_attributes(
          organization: current_user.organization,
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

      it "delivers confirmation instructions" do
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
      let(:another_organization) { create(:publisher) }
      let(:attributes) do
        super().merge(
          organization_type: another_organization.class.name,
          organization_id:   another_organization.id
        )
      end

      it "ignores the attributes to assign the publisher in the URL" do
        request
        expect(User.last.organization).to eq(current_user.organization)
      end
    end

    context "when using organization_name attribute" do
      let(:another_organization) { create(:publisher) }
      let(:attributes) do
        super()
          .except(:organization_id)
          .merge(
            organization_type: another_organization.class.name,
            organization_name: another_organization.name
          )
      end

      it "ignores the attributes to assign the publisher in the URL" do
        request
        expect(User.last.organization).to eq(current_user.organization)
      end
    end

    context "when using organization_data attribute in JSON" do
      let(:another_organization) { create(:publisher) }
      let(:attributes) do
        super()
          .except(:organization_id)
          .merge(
            organization_data: {
              type: another_organization.class.name,
              id:   another_organization.id
            }.to_json
          )
      end

      it "ignores the attributes to assign the publisher in the URL" do
        request
        expect(User.last.organization).to eq(current_user.organization)
      end
    end

    context "when using office_ids" do
      let(:ddfip)   { create(:ddfip) }
      let(:offices) { create_list(:office, 3, ddfip: ddfip) }
      let(:attributes) do
        super().merge(office_ids: offices[0..1].map(&:id))
      end

      context "when current organization is a DDFIP" do
        let(:organization) { ddfip }

        it "assigns the offices to the new user" do
          request
          expect(User.last.offices).to have(2).offices.and include(*offices[0..1])
        end
      end

      context "when current organization is a publisher" do
        let(:organization) { create(:publisher) }

        it "ignores the offices attributes" do
          request
          expect(User.last.offices).to be_empty
        end
      end

      context "when current organization is a collectivity" do
        let(:organization) { create(:collectivity) }

        it "ignores the offices attributes" do
          request
          expect(User.last.offices).to be_empty
        end
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
      it { expect(response).to redirect_to("/organisation/utilisateurs") }
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
