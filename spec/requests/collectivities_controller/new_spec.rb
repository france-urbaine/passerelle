# frozen_string_literal: true

require "rails_helper"

RSpec.describe "CollectivitiesController#new" do
  subject(:request) do
    get "/collectivites/new", as:
  end

  let(:as) { |e| e.metadata[:as] }

  context "when requesting HTML" do
    it { expect(response).to have_http_status(:success) }
    it { expect(response).to have_content_type(:html) }
    it { expect(response).to have_html_body }
  end

  context "when requesting JSON", as: :json do
    it { expect(response).to have_http_status(:not_acceptable) }
    it { expect(response).to have_content_type(:json) }
    it { expect(response).to have_empty_body }
  end
end
