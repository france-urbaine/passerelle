# frozen_string_literal: true

module Views
  module Territories
    class UpdateComponent < ApplicationViewComponent
      URL_ROOT        = "https://www.insee.fr/"
      URL_ROOT_REGEXP = /^#{URL_ROOT}/

      def initialize(params = {}, result = nil, referrer: nil)
        if params.is_a?(ActionController::Parameters)
          params = params
            .slice(:communes_url, :epcis_url)
            .permit(:communes_url, :epcis_url)
            .to_unsafe_h.symbolize_keys
        end

        @params   = params
        @result   = result
        @referrer = referrer
        super()
      end

      def redirection_path
        if @referrer.nil? && params[:redirect]
          params[:redirect]
        else
          @referrer
        end
      end

      def communes_url
        @communes_url ||= @params.fetch(:communes_url) do
          Passerelle::Application::DEFAULT_COMMUNES_URL.gsub(URL_ROOT_REGEXP, "")
        end
      end

      def epcis_url
        @epcis_url ||= @params.fetch(:epcis_url) do
          Passerelle::Application::DEFAULT_EPCIS_URL.gsub(URL_ROOT_REGEXP, "")
        end
      end
    end
  end
end
