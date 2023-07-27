# frozen_string_literal: true

module Territories
  class UpdateService
    include ::ActiveModel::Model
    include ::ActiveModel::Validations::Callbacks

    attr_accessor :communes_url, :epcis_url

    def validate(&)
      if super
        Result::Success.new("success")
      else
        Result::Failure.new(errors)
      end
    end

    def perform_now
      validate.tap do |result|
        ImportEPCIsJob.perform_now(epcis_url) if result.success?
        ImportCommunesJob.perform_now(communes_url) if result.success?
      end
    end

    def perform_later
      validate.tap do |result|
        ImportEPCIsJob.perform_later(epcis_url) if result.success?
        ImportCommunesJob.perform_later(communes_url) if result.success?
      end
    end

    before_validation :format_urls

    validates :epcis_url,    presence: true, url: true
    validates :communes_url, presence: true, url: true

    protected

    def format_urls
      self.communes_url = format_url(communes_url)
      self.epcis_url    = format_url(epcis_url)
      self
    end

    def format_url(url)
      url = URI.join("https://www.insee.fr/", url).to_s unless url.blank? || url.start_with?("http")
      url
    end
  end
end
