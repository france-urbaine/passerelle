# frozen_string_literal: true

require "rails_helper"

RSpec.describe "OfficeUsersController#edit" do
  subject(:request) do
    patch "/guichets/#{office.id}/utilisateurs", as:, params:
  end

  let(:as)     { |e| e.metadata[:as] }
  let(:params) { { office_users: updated_attributes } }

  let!(:office) { create(:office) }
  let!(:users)  { create_list(:user, 3, organization: office.ddfip, offices: []) }

  let(:updated_attributes) do
    { user_ids: users.map(&:id) }
  end

  context "when requesting HTML" do
    context "with valid parameters" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/guichets/#{office.id}") }

      it "updates the communes associated to the office" do
        expect {
          request
          office.users.reload
        }.to change {
          # Because default order is unpredictable.
          # We sort them by ID to avoid flacky test
          office.users.sort_by(&:id)
        }.from([])
          .to(users.sort_by(&:id))
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          type:  "success",
          title: "Les modifications ont été enregistrées avec succés.",
          delay: 3000
        )
      end
    end

    context "when the office is missing" do
      let(:office) { Office.new(id: Faker::Internet.uuid) }
      let(:users)  { create_list(:user, 3, :ddfip) }

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
