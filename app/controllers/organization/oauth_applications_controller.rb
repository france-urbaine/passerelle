# frozen_string_literal: true

module Organization
  class OauthApplicationsController < ApplicationController
    before_action :authorize!
    before_action :autocompletion_not_implemented!, only: :index

    def index
      @oauth_applications = authorize_oauth_applications_scope
      @oauth_applications, @pagy = index_collection(@oauth_applications)
    end

    def show
      @oauth_application = find_and_authorize_oauth_application
    end

    def new
      @oauth_application = build_oauth_application
      @referrer_path = referrer_path || organization_oauth_applications_path
    end

    def create
      @oauth_application = build_oauth_application(oauth_application_params)
      @oauth_application.sandbox = true unless current_organization.confirmed?

      @oauth_application.save

      respond_with @oauth_application,
        flash: true,
        location: -> { redirect_path || organization_oauth_applications_path }
    end

    def edit
      @oauth_application = find_and_authorize_oauth_application
      @referrer_path = referrer_path || organization_oauth_application_path(@oauth_application)
    end

    def update
      @oauth_application = find_and_authorize_oauth_application
      @oauth_application.update(oauth_application_params)

      respond_with @oauth_application,
        flash: true,
        location: -> { redirect_path || organization_oauth_applications_path }
    end

    def remove
      @oauth_application = find_and_authorize_oauth_application
      @referrer_path = referrer_path || organization_oauth_application_path(@oauth_application)
      return if referrer_path&.include?(organization_oauth_application_path(@oauth_application))

      @redirect_path = referrer_path
    end

    def destroy
      @oauth_application = find_and_authorize_oauth_application(allow_discarded: true)
      @oauth_application.discard

      respond_with @oauth_application,
        flash: true,
        actions: undiscard_organization_oauth_application_action(@oauth_application),
        location: redirect_path || organization_oauth_applications_path
    end

    def undiscard
      @oauth_application = find_and_authorize_oauth_application(allow_discarded: true)
      @oauth_application.undiscard

      respond_with @oauth_application,
        flash: true,
        location: redirect_path || referrer_path || organization_oauth_applications_path
    end

    def remove_all
      @oauth_applications = authorize_oauth_applications_scope
      @oauth_applications = filter_collection(@oauth_applications)
      @referrer_path = referrer_path || organization_oauth_applications_path(**selection_params)
    end

    def destroy_all
      @oauth_applications = authorize_oauth_applications_scope(as: :destroyable)
      @oauth_applications = filter_collection(@oauth_applications)
      @oauth_applications.quickly_discard_all

      respond_with @oauth_applications,
        flash: true,
        actions: undiscard_all_organization_oauth_applications_action,
        location: redirect_path || organization_oauth_applications_path
    end

    def undiscard_all
      @oauth_applications = authorize_oauth_applications_scope(as: :undiscardable)
      @oauth_applications = filter_collection(@oauth_applications)
      @oauth_applications.quickly_undiscard_all

      respond_with @oauth_applications,
        flash: true,
        location: redirect_path || referrer_path || organization_oauth_applications_path
    end

    private

    def authorize_oauth_applications_scope(as: :default)
      authorized(current_organization.oauth_applications.with_discarded, as:).strict_loading
    end

    def build_oauth_application(...)
      authorize_oauth_applications_scope.build(...)
    end

    def find_and_authorize_oauth_application(allow_discarded: false)
      scope =
        case current_organization
        when Publisher then current_organization.oauth_applications.with_discarded
        else OauthApplication.none
        end

      oauth_application = scope.find(params[:id])

      authorize! oauth_application
      only_kept! oauth_application unless allow_discarded

      oauth_application
    end

    def oauth_application_params
      authorized(params.fetch(:oauth_application, {}))
    end
  end
end
