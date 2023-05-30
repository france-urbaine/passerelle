# frozen_string_literal: true

require "rails_helper"

RSpec.describe "UsersController#update" do
  subject(:request) do
    patch "/utilisateurs/#{user.id}", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { user: attributes }) }

  let!(:user) { create(:user, first_name: "Guillaume", last_name: "Debailly") }

  let(:attributes) do
    { first_name: "Paul", last_name: "Lefebvre" }
  end

  describe "authorizations" do
    it_behaves_like "it requires authorization in HTML"
    it_behaves_like "it requires authorization in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to DDFIP admin"
    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to publisher admin"
    it_behaves_like "it denies access to colletivity user"
    it_behaves_like "it denies access to colletivity admin"
    it_behaves_like "it allows access to super admin"

    context "when user organization is the same as current user" do
      let(:user) { create(:user, organization: current_user.organization) }

      it_behaves_like "it allows access to DDFIP admin"
      it_behaves_like "it allows access to publisher admin"
      it_behaves_like "it allows access to colletivity admin"

      it_behaves_like "it denies access to publisher user"
      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it denies access to colletivity user"
    end

    context "when user is member of a collectivity owned by current user publisher organization" do
      let(:collectivity) { create(:collectivity, publisher: current_user.organization) }
      let(:user)         { create(:user, organization: collectivity) }

      it_behaves_like "it allows access to publisher admin"
      it_behaves_like "it allows access to publisher user"
    end
  end

  describe "responses" do
    context "when signed in as super admin" do
      before { sign_in_as(:super_admin) }

      context "with valid attributes" do
        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/utilisateurs") }

        it "updates the user" do
          expect { request and user.reload }
            .to  change(user, :updated_at)
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

      context "when assigning another organization in attributes" do
        let(:another_organization) { create(:publisher) }
        let(:attributes) do
          super().merge(
            organization_type: "Publisher",
            organization_id:   another_organization.id
          )
        end

        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/utilisateurs") }

        it "updates the user organization" do
          expect { request and user.reload }
            .to  change(user, :updated_at)
            .and change(user, :organization).to(another_organization)
        end
      end

      context "with invalid attributes" do
        let(:attributes) { super().merge(email: "") }

        it { expect(response).to have_http_status(:unprocessable_entity) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }
        it { expect { request and user.reload }.not_to change(user, :updated_at) }
        it { expect { request and user.reload }.not_to change(user, :name) }
      end

      context "with empty parameters", params: {} do
        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/utilisateurs") }
        it { expect(flash).to have_flash_notice }
        it { expect { request and user.reload }.not_to change(user, :updated_at) }
      end

      context "when the user is discarded" do
        before { user.discard }

        it { expect(response).to have_http_status(:gone) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }
      end

      context "when the user is missing" do
        before { user.destroy }

        it { expect(response).to have_http_status(:not_found) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }
      end

      context "with referrer header", headers: { "Referer" => "http://example.com/other/path" } do
        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/utilisateurs") }
        it { expect(flash).to have_flash_notice }
      end

      context "with redirect parameter" do
        let(:params) { super().merge(redirect: "/other/path") }

        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/other/path") }
        it { expect(flash).to have_flash_notice }
      end
    end

    context "when signed in as an organization admin" do
      before { sign_in_as(:organization_admin, organization: user.organization) }

      context "with valid attributes" do
        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/utilisateurs") }
        it { expect { request and user.reload }.to change(user, :updated_at) }
      end

      context "when assigning another organization in attributes" do
        let(:another_organization) { create(:publisher) }
        let(:attributes) do
          super().merge(
            organization_type: "Publisher",
            organization_id:   another_organization.id
          )
        end

        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/utilisateurs") }

        it "ignores the attribute" do
          expect { request and user.reload }
            .to  change(user, :updated_at)
            .and not_change(user, :organization)
        end
      end

      context "when assigning a super admin in attributes" do
        let(:attributes) { super().merge(super_admin: true) }

        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/utilisateurs") }

        it "ignores the attribute" do
          expect { request and user.reload }
            .to  change(user, :updated_at)
            .and not_change(user, :super_admin).from(false)
        end
      end

      context "when downgrading a super admin in attributes" do
        let(:user)       { create(:user, :super_admin) }
        let(:attributes) { super().merge(super_admin: false) }

        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/utilisateurs") }

        it "ignores the attribute" do
          expect { request and user.reload }
            .to  change(user, :updated_at)
            .and not_change(user, :super_admin).from(true)
        end
      end
    end

    context "when signed in as a publisher, owner of the user collectivity" do
      before { sign_in_as(organization: user.organization.publisher) }

      let(:user) { create(:user, :collectivity) }

      context "with valid attributes" do
        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/utilisateurs") }
        it { expect { request and user.reload }.to change(user, :updated_at) }
      end

      context "when assigning another organization in attributes" do
        let(:another_organization) { create(:publisher) }
        let(:attributes) do
          super().merge(
            organization_type: "Publisher",
            organization_id:   another_organization.id
          )
        end

        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/utilisateurs") }

        it "ignores the attribute" do
          expect { request and user.reload }
            .to  change(user, :updated_at)
            .and not_change(user, :organization)
        end
      end

      context "when assigning a super admin in attributes" do
        let(:attributes) { super().merge(super_admin: true) }

        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/utilisateurs") }

        it "ignores the attribute" do
          expect { request and user.reload }
            .to  change(user, :updated_at)
            .and not_change(user, :super_admin).from(false)
        end
      end

      context "when downgrading a super admin in attributes" do
        let(:user)       { create(:user, :collectivity, :super_admin) }
        let(:attributes) { super().merge(super_admin: false) }

        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/utilisateurs") }

        it "ignores the attribute" do
          expect { request and user.reload }
            .to  change(user, :updated_at)
            .and not_change(user, :super_admin).from(true)
        end
      end

      context "when assigning an organization admin in attributes" do
        let(:attributes) { super().merge(organization_admin: true) }

        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/utilisateurs") }

        it "ignores the attribute" do
          expect { request and user.reload }
            .to  change(user, :updated_at)
            .and not_change(user, :organization_admin).from(false)
        end
      end

      context "when downgrading an organization admin in attributes" do
        let(:user)       { create(:user, :collectivity, :organization_admin) }
        let(:attributes) { super().merge(organization_admin: true) }

        it { expect(response).to have_http_status(:see_other) }
        it { expect(response).to redirect_to("/utilisateurs") }

        it "ignores the attribute" do
          expect { request and user.reload }
            .to  change(user, :updated_at)
            .and not_change(user, :organization_admin).from(true)
        end
      end
    end
  end
end
