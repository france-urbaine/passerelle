# frozen_string_literal: true

module RequestTestHelpers
  module SharedResponseExamples
    extend ActiveSupport::Concern

    included do
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
      shared_examples "it allows access" do
        it do
          expect(response)
            .to  have_http_status(:success)
            .or  have_http_status(:redirect)
            .and not_redirect_to(new_user_session_path)
        end
      end

      # 2xx - Any success

      shared_examples "it responds successfully in HTML" do
        let(:as) { :html }

        it do
          expect { subject }
            .to invoke(:as).on(self).at_least(:once)

          expect(response)
            .to have_http_status(:no_content)
            .or(
              have_http_status(:success)
                .and(have_content_type(:html))
                .and(have_html_body)
            )
        end
      end

      shared_examples "it responds successfully in JSON" do
        let(:as) { :json }

        it do
          expect { subject }
            .to invoke(:as).on(self).at_least(:once)

          expect(response)
            .to have_http_status(:no_content)
            .or(
              have_http_status(:success)
                .and(have_content_type(:json))
                .and(have_json_body)
            )
        end
      end

      # 3xx - Any redirection

      shared_examples "it responds by redirecting in HTML to" do |expected_path|
        let(:as) { :html }

        it do
          expect { subject }
            .to invoke(:as).on(self).at_least(:once)

          expect(response)
            .to  have_http_status(:redirect)
            .and redirect_to(expected_path)
        end
      end

      # 401 - Unauthorized

      shared_examples "it responds with unauthorized in HTML" do
        let(:as) { :html }

        it do
          expect { subject }
            .to invoke(:as).on(self).at_least(:once)

          expect(response)
            .to  have_http_status(:unauthorized)
            .and have_content_type(:html)
            .and have_html_body
        end
      end

      shared_examples "it responds with unauthorized in JSON" do
        let(:as) { :json }

        it do
          expect { subject }
            .to invoke(:as).on(self).at_least(:once)

          expect(response)
            .to  have_http_status(:unauthorized)
            .and have_content_type(:json)
            .and have_json_body(error: "Vous devez d'abord vous authentifier.")
        end
      end

      # 403 - forbidden

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

      shared_examples "it responds with forbidden in JSON" do
        let(:as) { :json }

        it do
          expect { subject }
            .to invoke(:as).on(self).at_least(:once)

          expect(response)
            .to  have_http_status(:forbidden)
            .and have_content_type(:json)
            .and have_json_body(error: "Vous ne disposez pas des permissions suffisantes pour accéder à cette resource.")
        end
      end

      # 404 - Not Found

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

      shared_examples "it responds with not found in JSON" do
        let(:as) { :json }

        it do
          expect { subject }
            .to invoke(:as).on(self).at_least(:once)

          expect(response)
            .to  have_http_status(:not_found)
            .and have_content_type(:json)
            .and have_json_body(error: "La resource n'a pas été trouvée ou n'existe plus.")
        end
      end

      # 406 - Not Acceptable

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
            .and have_json_body(error: "La resource ne peut être retournée dans le format demandé.")
        end
      end

      # 409 - Gone

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

      shared_examples "it responds with gone in JSON" do
        let(:as) { :json }

        it do
          expect { subject }
            .to invoke(:as).on(self).at_least(:once)

          expect(response)
            .to  have_http_status(:gone)
            .and have_content_type(:json)
            .and have_json_body(error: "La resource n'est plus disponible ou est en cours de suppression.")
        end
      end

      # 422 - Unprocessable entity

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

      shared_examples "it responds with unprocessable entity in JSON" do
        let(:as) { :json }

        it do
          expect { subject }
            .to invoke(:as).on(self).at_least(:once)

          expect(response)
            .to  have_http_status(:unprocessable_entity)
            .and have_content_type(:json)
            .and have_json_body(include(:error))
        end
      end

      # HTML variants: Turbo-Frame, autocompletion, ...

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

      # HTML UI
      # Compound examples with contexts & responses examples
      # ----------------------------------------------------------------------------
      shared_examples "it requires to be signed in in HTML" do
        include_examples "it responds by redirecting in HTML to", "/connexion"
      end

      shared_examples "it requires to be signed in in JSON" do
        include_examples "it responds with unauthorized in JSON"
      end

      shared_examples "it allows access whithout being signed in" do
        include_examples "it allows access"
      end

      shared_examples "it allows access when signed in" do
        include_context "when signed in"
        include_examples "it allows access"
      end

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

      [
        "super admin",
        "admin",
        "DDFIP super admin",
        "DDFIP admin",
        "DDFIP user",
        "DGFIP super admin",
        "DGFIP admin",
        "DGFIP user",
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

      # JSON API : compound examples with contexts & responses examples
      # ----------------------------------------------------------------------------
      shared_examples "it requires an authentication through OAuth in JSON" do
        include_examples "it responds with unauthorized in JSON"
      end

      shared_examples "it requires an authentication through OAuth in HTML" do
        include_examples "it responds with unauthorized in HTML"
      end

      shared_examples "it allows access when authorized through OAuth" do
        include_context "when authorized through OAuth"
        include_examples "it allows access"
      end

      shared_examples "it denies access when authorized through OAuth" do
        include_context "when authorized through OAuth"
        include_examples "it responds with forbidden in JSON"
      end

      shared_examples "it responds with not found when authorized through OAuth" do
        include_context "when authorized through OAuth"
        include_examples "it responds with not found in JSON"
      end

      # rubocop:enable RSpec/MultipleExpectations
    end
  end
end
