# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Offices::UsersController#update_all" do
  subject(:request) do
    patch "/admin/guichets/#{office.id}/utilisateurs", as:, headers:, params:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, { office: attributes }) }

  let!(:ddfip)  { create(:ddfip) }
  let!(:office) { create(:office, ddfip: ddfip) }
  let!(:users)  { create_list(:user, 3, organization: ddfip) }

  let(:attributes) do
    { user_ids: users.map(&:id) }
  end

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    it_behaves_like "it denies access to DDFIP user"
    it_behaves_like "it denies access to DDFIP admin"
    it_behaves_like "it denies access to publisher user"
    it_behaves_like "it denies access to publisher admin"
    it_behaves_like "it denies access to collectivity user"
    it_behaves_like "it denies access to collectivity admin"

    it_behaves_like "it allows access to super admin"

    context "when the office is owned by the current organization" do
      let(:office) { create(:office, ddfip: current_user.organization) }

      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it denies access to DDFIP admin"
    end
  end

  describe "responses" do
    before { sign_in_as(:super_admin) }

    context "with valid attributes" do
      it { expect(response).to have_http_status(:see_other) }
      it { expect(response).to redirect_to("/admin/guichets/#{office.id}") }

      it "updates the users associated to the office" do
        # Because default order is unpredictable.
        # We sort users by ID to avoid flacky test
        #
        expect { request and office.users.reload }
          .to change { office.users.sort_by(&:id) }.from([]).to(users.sort_by(&:id))
      end

      it "sets a flash notice" do
        expect(flash).to have_flash_notice.to eq(
          scheme: "success",
          header: "Les modifications ont été enregistrées avec succés.",
          delay:  3000
        )
      end
    end

    context "when the office is discarded" do
      before { office.discard }

      it { expect(response).to have_http_status(:gone) }
      it { expect(response).to have_media_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when the office is missing" do
      before { office.destroy }

      it { expect(response).to have_http_status(:not_found) }
      it { expect(response).to have_media_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "when the DDFIP is discarded" do
      before { office.ddfip.discard }

      it { expect(response).to have_http_status(:gone) }
      it { expect(response).to have_media_type(:html) }
      it { expect(response).to have_html_body }
    end
  end
end
