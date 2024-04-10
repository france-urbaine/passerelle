# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Organization::SettingsController#update" do
  subject(:request) do
    patch "/organisation/parametres", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { organization: attributes }) }

  let(:attributes) do
    { name: "Solution & Territoire" }
  end

  describe "authorizing requests" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "when signed in" do
      it "authorizes with a policy" do
        expect { request }.to be_authorized_to(:manage?, :settings).with(Organization::SettingsPolicy)
      end
    end

    it_behaves_like "it denies access to super admin"
    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to collectivity user"

    it_behaves_like "it allows access to publisher admin"
    it_behaves_like "it allows access to DDFIP admin"
    it_behaves_like "it allows access to collectivity admin"
  end

  describe "authorized requests" do
    it_behaves_like "when signed in as admin" do
      let(:organization) { current_user.organization }

      it "authorizes params with a policy" do
        expect { request }.to have_authorized_scope(:action_controller_params).with(Organization::SettingsPolicy)
      end

      context "with valid attributes" do
        it "redirects to show page" do
          expect(response)
            .to  have_http_status(:see_other)
            .and redirect_to("/organisation/parametres")
        end

        it "updates the curent organization" do
          expect { request and organization.reload }
            .to  change(organization, :updated_at)
            .and change(organization, :name).to(attributes[:name])
        end

        it "sets a flash notice" do
          expect(flash).to have_flash_notice.to eq(
            scheme: "success",
            header: "Les modifications ont été enregistrées avec succés.",
            delay:  3000
          )
        end
      end

      context "with invalid attributes" do
        let(:attributes) { super().merge(name: "") }

        it "responds with unprocessable entity" do
          expect(response)
            .to  have_http_status(:unprocessable_entity)
            .and have_media_type(:html)
            .and have_html_body
        end
      end

      context "with empty parameters", params: {} do
        it "redirects to show page" do
          expect(response)
            .to  have_http_status(:see_other)
            .and redirect_to("/organisation/parametres")
        end

        it "doesn't update the curent organization" do
          expect { request and organization.reload }
            .not_to change(organization, :updated_at)
        end
      end
    end
  end
end
