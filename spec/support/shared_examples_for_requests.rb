# frozen_string_literal: true

RSpec.shared_context "with requests shared examples" do
  shared_examples "it requires authorization in HTML" do
    include_context "when requesting HTML"

    it do
      expect(response)
        .to have_http_status(:redirect)
        .and redirect_to("/connexion")
    end
  end

  shared_examples "it requires authorization in JSON" do
    include_context "when requesting JSON"

    it do
      expect(response)
        .to have_http_status(:unauthorized)
        .and have_content_type(:json)
    end
  end

  shared_examples "it allows access whithout being signed in" do
    include_examples "it allows access"
  end

  shared_examples "it allows access when signed in" do
    include_context "when signed in"
    include_examples "it allows access"
  end

  shared_examples "it responds with not acceptable in HTML whithout being signed in" do
    include_context "when requesting HTML"
    include_examples "it responds with not acceptable in HTML"
  end

  shared_examples "it responds with not acceptable in JSON whithout being signed in" do
    include_context "when requesting JSON"
    include_examples "it responds with not acceptable in JSON"
  end

  shared_examples "it responds with not acceptable in HTML when signed in" do
    include_context "when requesting HTML"
    include_context "when signed in"
    include_examples "it responds with not acceptable in HTML"
  end

  shared_examples "it responds with not acceptable in JSON when signed in" do
    include_context "when requesting JSON"
    include_context "when signed in"
    include_examples "it responds with not acceptable in JSON"
  end

  [
    "publisher user",
    "publisher admin",
    "DDFIP user",
    "DDFIP admin",
    "collectivity user",
    "collectivity admin",
    "super admin"
  ].each do |user_description|
    # All these shared examples accepts literal and proc attributes to defin user:
    # See `shared_context "when signed in"` for more info.
    #
    shared_examples "it allows access to #{user_description}" do |**options|
      include_context "when signed in as #{user_description}", **options
      include_examples "it allows access"
    end

    shared_examples "it denies access to #{user_description}" do |**options|
      include_context "when signed in as #{user_description}", **options

      it { expect(response).to have_http_status(:forbidden) }
    end

    shared_examples "it responds with not found to #{user_description}" do |**options|
      include_context "when signed in as #{user_description}", **options

      it { expect(response).to have_http_status(:not_found) }
    end

    shared_examples "it responds with not acceptable to #{user_description}" do |**options|
      include_context "when signed in as #{user_description}", **options

      it { expect(response).to have_http_status(:not_acceptable) }
    end
  end

  shared_examples "it allows access" do
    it do
      expect(response)
        .to have_http_status(:success)
        .or have_http_status(:redirect)
        .and not_redirect_to(new_user_session_path)
    end
  end

  shared_examples "it responds with not acceptable in HTML" do
    it do
      expect(response)
        .to have_http_status(:not_acceptable)
        .and have_content_type(:html)
        .and have_html_body
    end
  end

  shared_examples "it responds with not acceptable in JSON" do
    it do
      expect(response)
        .to have_http_status(:not_acceptable)
        .and have_content_type(:json)
    end
  end
end

RSpec.configure do |rspec|
  rspec.include_context "with requests shared examples", type: :request
end
