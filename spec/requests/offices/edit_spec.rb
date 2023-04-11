# frozen_string_literal: true

require "rails_helper"

RSpec.describe "OfficesController#edit" do
  subject(:request) do
    get "/guichets/#{office.id}/edit", as:
  end

  let(:as) { |e| e.metadata[:as] }

  let!(:office) { create(:office) }

  context "when requesting HTML" do
    it { expect(response).to have_http_status(:success) }
    it { expect(response).to have_content_type(:html) }
    it { expect(response).to have_html_body }

    context "when office is missing" do
      let(:office) { Office.new(id: Faker::Internet.uuid) }

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
