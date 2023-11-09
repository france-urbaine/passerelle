# frozen_string_literal: true

module UI
  # @display frame "content"
  #
  class CodeRequestExampleComponentPreview < ViewComponent::Preview
    # @label Default
    #
    def default; end

    # @label With custom headers
    #
    def with_headers; end

    # @label With authorization headers
    #
    def with_authorization_header; end

    # @label With JSON bodies
    #
    def with_json_bodies; end

    # @label With file upload
    #
    def with_file_upload; end

    # @label With file download
    #
    def with_file_download; end

    # @label Inside other elements
    #
    def inside_card; end
  end
end
