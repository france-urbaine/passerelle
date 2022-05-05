# frozen_string_literal: true

class TerritoriesUpdate
  include ActiveModel::API
  include ActiveModel::Validations::Callbacks

  attr_accessor :communes_url, :epcis_url

  URL_ROOT        = "https://www.insee.fr/"
  URL_ROOT_REGEXP = /^#{URL_ROOT}/

  class UrlValidator < ActiveModel::EachValidator
    REGEXP = URI::DEFAULT_PARSER.make_regexp("https")

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

  validates :epcis_url,    presence: true, url: true
  validates :communes_url, presence: true, url: true

  before_validation :format_urls

  def format_urls
    self.communes_url = format_url(communes_url)
    self.epcis_url    = format_url(epcis_url)
    self
  end

  def format_url(url)
    url = URI.join(URL_ROOT, url).to_s unless url.blank? || url.start_with?("http")
    url
  end

  def strip_domain_urls
    self.communes_url = communes_url.gsub(URL_ROOT_REGEXP, "") if communes_url.present?
    self.epcis_url    = epcis_url.gsub(URL_ROOT_REGEXP, "")    if epcis_url.present?
    self
  end

  def perform_now
    ImportEpcisJob.perform_now(epcis_url)
    ImportCommunesJob.perform_now(communes_url)
  end

  def perform_later
    ImportEpcisJob.perform_later(epcis_url)
    ImportCommunesJob.perform_later(communes_url)
  end
end