# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users::OrganizationSettingsController#update" do
  subject(:request) do
    put "/compte/organisation", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { organization: updated_attributes }) }

  let!(:organization) { create(:publisher, name: "Fiscalité & Territoire") }
  let!(:user)         { create(:user, organization: organization) }

  let(:updated_attributes) do
    { name: "Solution & Territoire" }
  end

  it_behaves_like "it requires authorization in HTML"
  it_behaves_like "it requires authorization in JSON"
  it_behaves_like "it doesn't accept JSON when signed in"
  it_behaves_like "it allows access to publisher user"
  it_behaves_like "it allows access to publisher admin"
  it_behaves_like "it allows access to DDFIP user"
  it_behaves_like "it allows access to DDFIP admin"
  it_behaves_like "it allows access to colletivity user"
  it_behaves_like "it allows access to colletivity admin"
  it_behaves_like "it allows access to super admin"

  context "when signed in" do
    before { sign_in(user) }

    context "with valid attributes" do
      it { expect(request && response).to have_http_status(:see_other) }
      it { expect(request && response).to redirect_to("/compte/organisation") }

      it "updates the curent organization" do
        expect {
          request
          organization.reload
        }.to change(organization, :updated_at)
          .and change(organization, :name).to("Solution & Territoire")
      end

      it "sets a flash notice" do
        request
        expect(flash).to have_flash_notice.to eq(
          type:  "success",
          title: "Les modifications ont été enregistrées avec succés.",
          delay: 3000
        )
      end
    end

    context "with empty parameters", params: {} do
      it { expect(request && response).to have_http_status(:see_other) }
      it { expect(request && response).to redirect_to("/compte/organisation") }
      it { expect(request && flash).to have_flash_notice }
      it { expect { request and organization.reload }.not_to change(organization, :updated_at) }
    end
  end
end
