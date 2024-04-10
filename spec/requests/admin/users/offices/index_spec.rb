# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin::Users::OfficesController#index" do
  subject(:request) do
    get "/admin/utilisateurs/guichets", as:, headers:, params:, xhr:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata.fetch(:params, ddfip_id: ddfips[0].id) }
  let(:xhr)     { |e| e.metadata[:xhr] }

  let!(:ddfips) { create_list(:ddfip, 2) }

  let!(:offices) do
    create_list(:office, 2, ddfip: ddfips[0]) +
      create_list(:office, 2, ddfip: ddfips[1])
  end

  let!(:user) do
    create(:user, organization: ddfips[0], offices: offices[0..1])
  end

  describe "authorizations" do
    it_behaves_like "it requires to be signed in in HTML"
    it_behaves_like "it requires to be signed in in JSON"
    it_behaves_like "it responds with not acceptable in JSON when signed in"

    context "when requesting HTML" do
      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it denies access to DDFIP admin"
      it_behaves_like "it denies access to publisher user"
      it_behaves_like "it denies access to publisher admin"
      it_behaves_like "it denies access to collectivity user"
      it_behaves_like "it denies access to collectivity admin"

      it_behaves_like "it responds with not acceptable to super admin"
    end

    context "when requesting Turbo-Frame", :xhr, headers: { "Turbo-Frame" => "user_offices_checkboxes" } do
      it_behaves_like "it denies access to DDFIP user"
      it_behaves_like "it denies access to DDFIP admin"
      it_behaves_like "it denies access to publisher user"
      it_behaves_like "it denies access to publisher admin"
      it_behaves_like "it denies access to collectivity user"
      it_behaves_like "it denies access to collectivity admin"

      it_behaves_like "it allows access to super admin"
    end
  end

  describe "responses" do
    before { sign_in_as(:super_admin) }

    let(:headers) { { "Turbo-Frame" => "user_offices_checkboxes" } }
    let(:xhr)     { true }

    context "without ddfip_id params", params: {} do
      it { expect(response).to have_http_status(:bad_request) }
      it { expect(response).to have_media_type(:html) }
      it { expect(response).to have_html_body }
    end

    context "with ddfip_id params" do
      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_media_type(:html) }
      it { expect(response).to have_html_body.with_turbo_frame("user_offices_checkboxes") }
    end

    context "with ddfip_id and pre-check offices params" do
      let(:params) do
        {
          ddfip_id:   ddfips[0].id,
          office_ids: offices.take(1).map(&:id)
        }
      end

      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_media_type(:html) }
      it { expect(response).to have_html_body.with_turbo_frame("user_offices_checkboxes") }
    end

    context "with ddfip_id and user_id params" do
      let(:params) do
        {
          ddfip_id: ddfips[0].id,
          user_id:  user.id
        }
      end

      it { expect(response).to have_http_status(:success) }
      it { expect(response).to have_media_type(:html) }
      it { expect(response).to have_html_body.with_turbo_frame("user_offices_checkboxes") }
    end
  end
end
