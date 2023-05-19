# frozen_string_literal: true

RSpec.shared_examples "it requires authorization in HTML" do
  include_context("when requesting HTML")
  it { expect(response).to have_http_status(:redirect) }
  it { expect(response).to redirect_to("/connexion") }
end

RSpec.shared_examples "it requires authorization in JSON" do
  include_context("when requesting JSON")
  it { expect(response).to have_http_status(:unauthorized) }
  it { expect(response).to have_content_type(:json) }
end

RSpec.shared_examples "it doesn't accept HTML when signed in" do
  include_context("when requesting HTML")
  include_context("when signed in")
  it { expect(response).to have_http_status(:not_acceptable) }
  it { expect(response).to have_content_type(:html) }
  it { expect(response).to have_html_body }
end

RSpec.shared_examples "it doesn't accept JSON when signed in" do
  include_context("when requesting JSON")
  include_context("when signed in")
  it { expect(response).to have_http_status(:not_acceptable) }
  it { expect(response).to have_content_type(:json) }
end

RSpec.shared_context "when requesting HTML" do
  let(:as) { :html }
end

RSpec.shared_context "when requesting JSON" do
  let(:as) { :json }
end

RSpec.shared_context "when signed in" do
  before do |example|
    signed_as = Array.wrap(example.metadata[:signed_as])
    sign_in_as(*signed_as)
  end
end

{
  "publisher user"          => %i[publisher],
  "publisher admin"         => %i[publisher organization_admin],
  "publisher super admin"   => %i[publisher super_admin],
  "DDFIP user"              => %i[ddfip],
  "DDFIP admin"             => %i[ddfip organization_admin],
  "DDFIP super admin"       => %i[ddfip super_admin],
  "colletivity user"        => %i[collectivity],
  "colletivity admin"       => %i[collectivity organization_admin],
  "colletivity super admin" => %i[collectivity super_admin],
  "super admin"             => %i[super_admin]
}.each do |user_description, user_traits|
  RSpec.shared_examples "it forbids access to #{user_description}" do
    before { sign_in_as(*user_traits) }

    it { expect(response).to have_http_status(:forbidden) }
  end

  RSpec.shared_examples "it allows access to #{user_description}" do
    before { sign_in_as(*user_traits) }

    it do
      expect(response)
        .to have_http_status(:success)
        .or have_http_status(:redirect)
    end
  end
end

RSpec.configure do |rspec|
  rspec.include_context "when signed in", :signed_as
  rspec.include_context "when signed in", signed_in: true
end
