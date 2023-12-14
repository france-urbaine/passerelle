# frozen_string_literal: true

module UI
  class CodeRequestExampleComponent < ApplicationViewComponent
    define_component_helper :code_request_example_component

    DEFAULT_ACCESS_TOKEN   = "HgAxkdHZUvlBjuuWweLKwsJ6InRfZoZ-GHyFtbrS03k"
    DEFAULT_CONTENT_LENGTH = 71_475

    def initialize(verb, url, response: {}, request: {}, json: false, authorization: false, interpolations: {})
      @verb             = verb
      @url              = url
      @json             = json
      @authorization    = authorization
      @interpolations   = interpolations

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
      URI(@url)
    end

    def before_render
      @request_headers["Authorization"] ||= "Bearer $ACCESS_TOKEN" if @authorization
      @interpolations["ACCESS_TOKEN"]   ||= DEFAULT_ACCESS_TOKEN
      @interpolations["CONTENT_LENGTH"] ||= DEFAULT_CONTENT_LENGTH
    end

    def curl_command(indent: 0, options: [])
      options = command_options(options)

      command = []
      command << "curl #{options} -X #{@verb} #{url}".squish

      curl_headers.sort_by(&:first).each do |(key, value)|
        command << "  -H \"#{key}: #{value}\""
      end

      command << "  -d '#{request_body}'" if @request_body.present?
      command << "  --data-binary @#{@request_file}" if @request_file.present?

      command.map! do |line|
        (" " * indent) + line
      end

      sanitize(command.join(" \\\n"))
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

    def httpie_command(indent: 0, options: %w[v])
      options << "j" if @json
      options = command_options(options)

      command = []
      command << "http #{options} #{@verb} #{url}".squish

      httpie_headers.sort_by(&:first).each do |(key, value)|
        command << "  #{key}:\"#{value}\""
      end

      command << "  --raw='#{request_body}'" if @request_body.present?
      command << "  @#{@request_file}" if @request_file.present?

      command.map! do |line|
        (" " * indent) + line
      end

      sanitize(command.join(" \\\n"))
    end

    def httpie_headers
      headers = @request_headers.dup
      headers["Accept"] ||= "application/json" if @json
      headers
    end

    def command_options(options)
      single_letters = options.select { |o| o.size == 1 }.sort

      output = []
      output += (options - single_letters).map { |o| "--#{o}" }
      output << "-#{single_letters.join}" if single_letters.any?
      output.join(" ")
    end

    def request_headers_output
      headers = @request_headers.dup

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

    def interpolate(input)
      return unless input

      @interpolations.each do |key, value|
        input = input.to_s
          .sub("'$#{key}'", value.to_s)
          .sub("$#{key}", value.to_s)
      end

      input
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
