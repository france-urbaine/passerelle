# frozen_string_literal: true

require "net/http"

module Downloader
  module_function

  DOWNLOAD_PATH = ENV.fetch("DOWNLOAD_PATH") do
    Rails.env.test? ? "tmp/test/download" : "tmp/download"
  end

  def call(url)
    url        = follow_redirections(url)
    filename   = File.basename(url)
    local_path = Rails.root.join(DOWNLOAD_PATH, filename)

    local_path.delete if local_path.exist?
    local_path.dirname.mkpath

    local_path.open("wb") do |file|
      connect(url) do |http, path|
        http.request_get(path) do |response|
          response.read_body do |segment|
            file.write(segment)
          end
        end
      end
    end

    local_path
  end

  def follow_redirections(url)
    loop do
      response = head(url)
      break url unless response["location"]

      url = response["location"]
    end
  end

  def head(url)
    connect(url) { |http, path| http.head(path) }
  end

  def connect(url)
    uri = URI.parse(url)
    ssl = uri.scheme == "https"

    Net::HTTP.start(uri.hostname, uri.port, use_ssl: ssl) do |http|
      yield(http, uri.path)
    end
  end
end
