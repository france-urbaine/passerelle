# frozen_string_literal: true

RSpec.shared_context "with requests shared examples" do
  # rubocop:disable RSpec/MultipleExpectations
  #
  # Most shared examples depend on the fact that `let` helpers are called.
  # First, verify that helpers are called when calling subject,
  # otherwise it could lead to false positive
  #
  # Then, assert the response
  #

  # Reponses examples
  # ----------------------------------------------------------------------------
  shared_examples "it requires to be signed in in HTML" do
    let(:as) { :html }

    it do
      expect { subject }
        .to invoke(:as).on(self).at_least(:once)

      expect(response)
        .to  have_http_status(:redirect)
        .and redirect_to("/connexion")
    end
  end

  shared_examples "it requires to be signed in in JSON" do
    let(:as) { :json }

    it do
      expect { subject }
        .to invoke(:as).on(self).at_least(:once)

      expect(response)
        .to  have_http_status(:unauthorized)
        .and have_content_type(:json)
    end
  end

  shared_examples "it allows access whithout being signed in" do
    include_examples "it allows access"
  end

  shared_examples "it allows access" do
    it do
      expect(response)
        .to  have_http_status(:success)
        .or  have_http_status(:redirect)
        .and not_redirect_to(new_user_session_path)
    end
  end

  shared_examples "it responds successfully in HTML" do
    let(:as) { :html }

    it do
      expect { subject }
        .to invoke(:as).on(self).at_least(:once)

      expect(response)
        .to  have_http_status(:success)
        .and have_content_type(:html)
        .and have_html_body
    end
  end

  shared_examples "it responds by redirecting to" do |expected_path|
    it do
      expect(response)
        .to  have_http_status(:see_other)
        .and redirect_to(expected_path)
    end
  end

  shared_examples "it responds with not acceptable in HTML" do
    let(:as) { :html }

    it do
      expect { subject }
        .to invoke(:as).on(self).at_least(:once)

      expect(response)
        .to  have_http_status(:not_acceptable)
        .and have_content_type(:html)
        .and have_html_body
    end
  end

  shared_examples "it responds with not acceptable in JSON" do
    let(:as) { :json }

    it do
      expect { subject }
        .to invoke(:as).on(self).at_least(:once)

      expect(response)
        .to  have_http_status(:not_acceptable)
        .and have_content_type(:json)
    end
  end

  shared_examples "it responds with not found in HTML" do
    let(:as) { :html }

    it do
      expect { subject }
        .to invoke(:as).on(self).at_least(:once)

      expect(response)
        .to  have_http_status(:not_found)
        .and have_content_type(:html)
        .and have_html_body
    end
  end

  shared_examples "it responds with forbidden in HTML" do
    let(:as) { :html }

    it do
      expect { subject }
        .to invoke(:as).on(self).at_least(:once)

      expect(response)
        .to  have_http_status(:forbidden)
        .and have_content_type(:html)
        .and have_html_body
    end
  end

  shared_examples "it responds with gone in HTML" do
    let(:as) { :html }

    it do
      expect { subject }
        .to invoke(:as).on(self).at_least(:once)

      expect(response)
        .to  have_http_status(:gone)
        .and have_content_type(:html)
        .and have_html_body
    end
  end

  shared_examples "it responds with unprocessable entity in HTML" do
    let(:as) { :html }

    it do
      expect { subject }
        .to invoke(:as).on(self).at_least(:once)

      expect(response)
        .to  have_http_status(:unprocessable_entity)
        .and have_content_type(:html)
        .and have_html_body
    end
  end

  shared_examples "it responds with requested Turbo-Frame" do |frame|
    let(:headers) { (super() || {}).merge("Turbo-Frame" => frame) }
    let(:xhr)     { true }

    it do
      expect { subject }
        .to  invoke(:headers).on(self).at_least(:once)
        .and invoke(:xhr).on(self).at_least(:once)

      expect(response)
        .to  have_http_status(:success)
        .and have_content_type(:html)
        .and have_html_body.with_turbo_frame(frame)
    end
  end

  shared_examples "it responds with not implemented when requesting autocompletion" do
    let(:headers) { (super() || {}).merge("Accept-Variant" => "autocomplete") }
    let(:xhr)     { true }

    it do
      expect { subject }
        .to  invoke(:headers).on(self).at_least(:once)
        .and invoke(:xhr).on(self).at_least(:once)

      expect(response)
        .to  have_http_status(:not_implemented)
        .and have_content_type(:html)
        .and have_html_body
    end
  end

  # Compound examples with contexts & responses examples
  # ----------------------------------------------------------------------------
  shared_examples "it responds with not acceptable in HTML whithout being signed in" do
    include_examples "it responds with not acceptable in HTML"
  end

  shared_examples "it responds with not acceptable in JSON whithout being signed in" do
    include_examples "it responds with not acceptable in JSON"
  end

  shared_examples "it responds with not acceptable in HTML when signed in" do
    include_context "when signed in"
    include_examples "it responds with not acceptable in HTML"
  end

  shared_examples "it responds with not acceptable in JSON when signed in" do
    include_context "when signed in"
    include_examples "it responds with not acceptable in JSON"
  end

  shared_examples "it allows access when signed in" do
    include_context "when signed in"
    include_examples "it allows access"
  end

  [
    "super admin",
    "admin",
    "DDFIP super admin",
    "DDFIP admin",
    "DDFIP user",
    "publisher super admin",
    "publisher admin",
    "publisher user",
    "collectivity super admin",
    "collectivity admin",
    "collectivity user"
  ].each do |user_description|
    # All these shared examples accepts literal and proc attributes to define user:
    # See `shared_context "when signed in"` for more info.
    #
    shared_examples "it allows access to #{user_description}" do |**options|
      include_context "when signed in as #{user_description}", **options
      include_examples "it allows access"
    end

    shared_examples "it denies access to #{user_description}" do |**options|
      include_context "when signed in as #{user_description}", **options
      include_examples "it responds with forbidden in HTML"
    end

    shared_examples "it responds with not found to #{user_description}" do |**options|
      include_context "when signed in as #{user_description}", **options
      include_examples "it responds with not found in HTML"
    end

    shared_examples "it responds with not acceptable to #{user_description}" do |**options|
      include_context "when signed in as #{user_description}", **options
      include_examples "it responds with not acceptable in HTML"
    end
  end

  # rubocop:enable RSpec/MultipleExpectations
end

RSpec.configure do |rspec|
  rspec.include_context "with requests shared examples", type: :request
end
