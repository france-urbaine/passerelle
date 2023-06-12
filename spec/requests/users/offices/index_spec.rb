# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Users::OfficesController#index" do
  subject(:request) do
    get "/utilisateurs/offices", as:, headers:, params:, xhr:
  end

  let(:as)      { |e| e.metadata[:as] }
  let(:headers) { |e| e.metadata[:headers] }
  let(:params)  { |e| e.metadata[:params] }
  let(:xhr)     { |e| e.metadata[:xhr] }

  let!(:ddfips) { create_list(:ddfip, 2) }

  let!(:offices) do
    create_list(:office, 2, ddfip: ddfips[0]) +
      create_list(:office, 2, ddfip: ddfips[1])
  end

  let!(:user) do
    create(:user, organization: ddfips[0], offices: offices[0..1])
  end

  it_behaves_like "it requires to be signed in in HTML"
  it_behaves_like "it requires to be signed in in JSON"
  it_behaves_like "it responds with not acceptable in JSON when signed in"

  it_behaves_like "it denies access to DDFIP user"
  it_behaves_like "it denies access to publisher user"
  it_behaves_like "it denies access to publisher admin"
  it_behaves_like "it denies access to collectivity user"
  it_behaves_like "it denies access to collectivity admin"

  it_behaves_like "it responds with not acceptable to DDFIP admin"
  it_behaves_like "it responds with not acceptable to super admin"

  context "when requesting Turbo-Frame", headers: { "Turbo-Frame" => "user_offices_checkboxes" }, xhr: true do
    context "when signed in as a super admin" do
      before { sign_in_as(:super_admin) }

      context "without ddfip_id params" do
        it { expect(response).to have_http_status(:bad_request) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_html_body }
      end

      context "with ddfip_id params" do
        let(:params) { { ddfip_id: ddfips[0].id } }

        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_partial_html.with_turbo_frame("user_offices_checkboxes") }
      end

      context "with ddfip_id and pre-check offices params" do
        let(:params) do
          {
            ddfip_id:   ddfips[0].id,
            office_ids: offices.take(1).map(&:id)
          }
        end

        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_partial_html.with_turbo_frame("user_offices_checkboxes") }
      end

      context "with ddfip_id and existing user params" do
        let(:params) do
          {
            ddfip_id: ddfips[0].id,
            user_id:  user.id
          }
        end

        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_partial_html.with_turbo_frame("user_offices_checkboxes") }
      end
    end

    context "when signed in as a DDFIP admin" do
      before { sign_in_as(:organization_admin, organization: ddfips.first) }

      context "without ddfip_id params" do
        it { expect(response).to have_http_status(:success) }
        it { expect(response).to have_content_type(:html) }
        it { expect(response).to have_partial_html.with_turbo_frame("user_offices_checkboxes") }
      end
    end
  end
end
