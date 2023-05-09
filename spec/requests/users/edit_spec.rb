# frozen_string_literal: true

require "rails_helper"

RSpec.describe "UsersController#edit" do
  subject(:request) do
    get "/utilisateurs/#{user.id}/edit", as:
  end

  let(:as) { |e| e.metadata[:as] }

  let!(:user) { create(:user) }

  context "when requesting HTML" do
    context "when the user is accessible" do
      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when the user is discarded" do
      let(:user) { create(:user, :discarded) }

      it { expect(response).to have_http_status(:gone) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when the user is missing" do
      let(:user) { User.new(id: Faker::Internet.uuid) }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end
  end

  context "when requesting JSON", as: :json do
    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:json) }
    it { expect(response).to have_empty_body }
  end
end
