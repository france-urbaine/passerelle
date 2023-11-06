# frozen_string_literal: true

module UI
  class CodeRequestComponent < ApplicationViewComponent
    def initialize(verb, url, response: {}, request: {}, json: false, authorization: true)
      @verb             = verb
      @url              = url
      @json             = true
      @authorization    = authorization

      @response_code    = response.fetch(:code, 200)
      @response_body    = response.fetch(:body, nil)
      @response_headers = response.fetch(:headers, {})

      @request_body     = request.fetch(:body, nil)
      @request_file     = request.fetch(:file, nil)
      @request_headers  = request.fetch(:headers, {})

      if json
        @response_headers["Content-Type"] ||= "application/json" if @response_body
        @request_headers["Content-Type"]  ||= "application/json" if @request_body
        @request_headers["Accept"]        ||= "application/json"
      end

      @request_headers["Authorization"] ||= "Bearer $ACCESS_TOKEN" if authorization

      raise "use request_body or request_file, not both" if @request_body && @request_file

      super()
    end

    def url
      URI.join(api_url, @url)
    end

    def request_body_formatted
      return nil if @request_body.blank?

      if @json && (@request_body.is_a?(Hash) || @request_body.is_a?(Array))
        @request_body.to_json
      else
        @request_body
      end
    end

    def response_body_formatted
      return nil if @response_body.blank?

      if @json && (@response_body.is_a?(Hash) || @response_body.is_a?(Array))
        @response_body.to_json
      else
        @response_body
      end
    end
  end
end
