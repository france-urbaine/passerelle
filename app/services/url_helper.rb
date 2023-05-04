# frozen_string_literal: true

class UrlHelper < String
  def initialize(url)
    @url = url
    super(url)
  end

  def base
    uri = URI.parse(@url)
    uri.query = nil
    uri.fragment = nil

    self.class.new(uri.to_s)
  end

  def join(params)
    return self if params.empty?

    query = params.to_query
    join  = @url.include?("?") ? "&" : "?"

    self.class.new("#{@url}#{join}#{query}")
  end
end
