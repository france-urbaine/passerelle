# frozen_string_literal: true

require "rails_helper"

RSpec.describe "OfficeUsersController#destroy" do
  subject(:request) do
    delete "/guichets/#{office.id}/utilisateurs/#{user.id}", as:
  end

  let(:as) { |e| e.metadata[:as] }

  let!(:office) { create(:office) }
  let!(:user)   { create(:user, organization: office.ddfip, offices: [office]) }

  context "when requesting HTML" do
    it { expect(response).to have_http_status(:see_other) }
    it { expect(response).to redirect_to("/guichets/#{office.id}") }

    it "removes the users from the office" do
      expect {
        request
        office.users.reload
      }.to change(office, :user_ids).from([user.id]).to([])
    end

    it "doesn't destroy the users" do
      expect {
        request
        user.reload
      }.not_to change(user, :discarded_at).from(nil)
    end

    it "sets a flash notice" do
      expect(flash).to have_flash_notice.to eq(
        type:  "success",
        title: "L'utilisateur a été retiré du guichet.",
        delay: 3000
      )
    end

    context "when user doesn't belong to office" do
      let(:user) { create(:user, organization: office.ddfip) }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when user doesn't belong to ddfip" do
      let(:user) { create(:user) }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_content_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when user is missing" do
      let(:user) { Office.new(id: Faker::Internet.uuid) }

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
