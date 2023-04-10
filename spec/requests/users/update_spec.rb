# frozen_string_literal: true

require "rails_helper"

RSpec.describe "UsersController#update" do
  subject(:request) { patch "/utilisateurs/#{user.id}", headers:, params: }

  let(:headers) { {} }
  let(:params)  { { user: { first_name: "Paul", last_name: "Lefebvre" } } }
  let(:user)    { create(:user, first_name: "Guillaume", last_name: "Debailly") }

  context "when requesting HTML with valid parameters" do
    it { expect(response).to have_http_status(:found) }
    it { expect(response).to redirect_to("/utilisateurs") }

    it "is expected to update the record" do
      expect {
        request
        user.reload
      } .to  change(user, :updated_at)
        .and change(user, :first_name).to("Paul")
        .and change(user, :last_name).to("Lefebvre")
    end
  end

  context "when requesting HTML with invalid parameters" do
    let(:params) { { user: { email: "" } } }

    it { expect(response).to have_http_status(:unprocessable_entity) }
    it { expect(response).to have_content_type(:html) }
    it { expect(response).to have_html_body }

    it "is expected to not update the record" do
      expect {
        request
        user.reload
      } .to  maintain(user, :updated_at)
        .and maintain(user, :first_name)
        .and maintain(user, :last_name)
    end
  end

  describe "when requesting JSON" do
    let(:headers) { { "Accept" => "application/json" } }

    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:json) }
    it { expect(response).to have_empty_body }

    it "is expected to not update the record" do
      expect {
        request
        user.reload
      } .to  maintain(user, :updated_at)
        .and maintain(user, :first_name)
        .and maintain(user, :last_name)
    end
  end
end
