# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Offices::UsersController#remove" do
  subject(:request) do
    get "/guichets/#{office.id}/utilisateurs/#{user.id}/remove", as:
  end

  let(:as) { |e| e.metadata[:as] }

  let!(:ddfip)  { create(:ddfip) }
  let!(:office) { create(:office, ddfip: ddfip) }
  let!(:user)   { create(:user, organization: ddfip, offices: [office]) }

  context "when requesting HTML" do
    context "when the user is accessible" do
      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when the user is already discarded" do
      let(:user) { create(:user, :discarded, organization: ddfip, offices: [office]) }

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
      let(:user)   { create(:user, organization: ddfip) }

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
