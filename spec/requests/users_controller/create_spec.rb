# frozen_string_literal: true

require "rails_helper"

RSpec.describe "UsersController#create", type: :request do
  subject(:request) { post "/utilisateurs", headers:, params: }

  let(:headers)       { {} }
  let(:params)        { { user: attributes } }
  let(:organization)  { create(%i[publisher collectivity ddfip].sample) }

  let(:attributes) do
    attributes_for(:user).slice(
      :first_name,
      :last_name,
      :email
    ).merge(
      organization_type: organization.class.name,
      organization_id:   organization.id
    )
  end

  context "when requesting HTML with valid parameters" do
    it { expect(response).to have_http_status(:found) }
    it { expect(response).to redirect_to("/utilisateurs") }

    it "is expected to create a record" do
      expect { request }.to change(User, :count).by(1)
    end
  end

  context "when requesting HTML with invalid parameters" do
    let(:attributes) { { name: "", siren: "" } }

    it { expect(response).to have_http_status(:unprocessable_entity) }
    it { expect(response).to have_content_type(:html) }
    it { expect(response).to have_html_body }

    it "is expected to not create any record" do
      expect { request }.to maintain(User, :count).from(0)
    end
  end

  describe "when requesting JSON" do
    let(:headers) { { "Accept" => "application/json" } }

    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:json) }
    it { expect(response).to have_empty_body }

    it "is expected to not create any record" do
      expect{ request }.to maintain(User, :count).from(0)
    end
  end
end
