# frozen_string_literal: true

class UrlValidator < ActiveModel::EachValidator
  REGEXP = URI::DEFAULT_PARSER.make_regexp("https").freeze

  def validate_each(record, attribute, value)
    return if value.blank?

    if !value.match?(REGEXP)
      record.errors.add(attribute, :invalid_url)
    elsif !value.match?(/\.zip$/)
      record.errors.add(attribute, :invalid_extension)
    elsif !Downloader.head(value).code.in?("200".."299")
      record.errors.add(attribute, :dead_link)
    end
  end
end
