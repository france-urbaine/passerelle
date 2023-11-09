# frozen_string_literal: true

module UI
  class CodeRequestExampleComponent < ApplicationViewComponent
    DEFAULT_ACCESS_TOKEN   = "HgAxkdHZUvlBjuuWweLKwsJ6InRfZoZ-GHyFtbrS03k"
    DEFAULT_CONTENT_LENGTH = 71_475

    def initialize(verb, url, response: {}, request: {}, json: false, authorization: false)
      @verb             = verb
      @url              = url
      @json             = json
      @authorization    = authorization

      @request_body     = request.fetch(:body, nil)
      @request_file     = request.fetch(:file, nil)
      @request_headers  = request.fetch(:headers, {})

      @response_code    = response.fetch(:code, 200)
      @response_body    = response.fetch(:body, nil)
      @response_file    = response.fetch(:file, nil)
      @response_headers = response.fetch(:headers, {})

      raise "use request_body or request_file, not both" if @request_body && @request_file

      super()
    end

    def url
      URI.join(api_url, @url)
    end

    def before_render
      @request_headers["Authorization"] ||= "Bearer $ACCESS_TOKEN" if @authorization
    end

    def curl_headers
      headers = @request_headers.dup

      if @json
        headers["Accept"]       ||= "application/json"
        headers["Content-Type"] ||= "application/json" if @request_body.present?
      end

      if @request_file.present?
        headers["Content-Type"]   ||= MiniMime.lookup_by_filename(@request_file).content_type
        headers["Content-Length"] ||= DEFAULT_CONTENT_LENGTH
      end

      headers
    end

    def httpie_headers
      headers = @request_headers.dup
      headers["Accept"] ||= "application/json" if @json
      headers
    end

    def request_headers_output
      headers = @request_headers.dup

      if headers.key?("Authorization")
        headers["Authorization"] = headers["Authorization"].sub("$ACCESS_TOKEN", DEFAULT_ACCESS_TOKEN)
      end

      if @json
        headers["Accept"]       ||= "application/json"
        headers["Content-Type"] ||= "application/json" if @request_body.present?
      end

      if @request_file.present?
        headers["Content-Type"]   ||= MiniMime.lookup_by_filename(@request_file).content_type
        headers["Content-Length"] ||= DEFAULT_CONTENT_LENGTH
      end

      headers["Accept"] ||= "*/*"
      headers
    end

    def response_headers_output
      headers = @response_headers.dup

      headers["Content-Type"] ||= "application/json; charset=utf-8" if @json && @response_body.present?

      if @response_file.present?
        headers["Content-Type"]   ||= MiniMime.lookup_by_filename(@response_file).content_type
        headers["Content-Length"] ||= DEFAULT_CONTENT_LENGTH
      end

      headers
    end

    def response_code_in_words
      Rack::Utils::HTTP_STATUS_CODES[@response_code]
    end

    def request_body
      return nil if @request_body.blank?

      if @json && (@request_body.is_a?(Hash) || @request_body.is_a?(Array))
        @request_body.to_json
      else
        @request_body
      end
    end

    def response_body
      return nil if @response_body.blank?

      if @json && (@response_body.is_a?(Hash) || @response_body.is_a?(Array))
        @response_body.to_json
      else
        @response_body
      end
    end
  end
end
