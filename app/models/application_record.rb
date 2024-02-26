# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include AdvancedOrder
  include AdvancedSearch
  include Discardable
  include QueryRecords::Arrays
  include QueryRecords::Match
  include ScoredOrder
  include SkipUniquenessValidation

  class ArrayValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      record.errors.add(attribute, :must_be_an_array, **options) unless value.is_a?(Array)
    end
  end

  primary_abstract_class

  self.abstract_class        = true
  self.implicit_order_column = :created_at

  SIREN_REGEXP  = /\A[0-9]{9}\Z/
  PHONE_REGEXP  = /\A(0|\+(33|590|594|596|262|269))?[0-9]{9}\Z/
  EMAIL_REGEXP  = URI::MailTo::EMAIL_REGEXP
  DOMAIN_REGEXP = /\A#{EMAIL_REGEXP.source.split('@').last}/
  NAF_REGEXP    = /\A[0-9]{2}\.[0-9]{2}[A-Z]\Z/

  CODE_REGION_REGEXP      = /\A[0-9]{2}\Z/
  CODE_DEPARTEMENT_REGEXP = /\A(2[AB]|[0-9]{2}|9[0-9]{2})\Z/
  CODE_INSEE_REGEXP       = /\A(2[AB]|[0-9]{2})[0-9]{3}\Z/

  INVARIANT_REGEXP                 = /\A[0-9]{10}\Z/
  CODE_RIVOLI_REGEXP               = /\A[0-9A-Z]{4}\Z/
  NUMERO_BATIMENT_REGEXP           = /\A(?:[A-Z]|[0-9]{1,2})\Z/
  NUMERO_ESCALIER_REGEXP           = /\A[0-9]{1,2}\Z/
  NUMERO_NIVEAU_REGEXP             = /\A[0-9]{1,2}\Z/
  NUMERO_PORTE_REGEXP              = /\A[0-9]{1,2}\Z/
  NUMERO_ORDRE_PORTE_REGEXP        = /\A[0-9]{1,3}\Z/
  NUMERO_ORDRE_PROPRIETAIRE_REGEXP = /\A[0A-Za-z*+]\s?[0-9]{5}\s?(?:[0-9]{2})?\Z/

  # https://rubular.com/r/GoPbmeSUeTZVEd
  PARCELLE_REGEXP = /
    \A
      (?:(?<prefix>[0-9]{3})\s?)?
      (?:0(?=[A-Z]))?
      (?<section>[A-Z]{1,2}|[0-9]{2}(?=\s?[0-9]{4}))\s?
      (?<plan>[0-9]{1,4})
    \Z
  /x

  DATE_REGEXP = %r{
    (?<year>  (19|20)\d{2}){0}
    (?<month> #{Regexp.union(Array('01'..'12'))}){0}
    (?<day>   #{Regexp.union(Array('01'..'31'))}){0}

    \A(
      \g<year>\g<month>\g<day>|
      \g<year>/\g<month>/\g<day>|
      \g<year>-\g<month>-\g<day>|
      \g<day>\g<month>\g<year>|
      \g<day>/\g<month>/\g<year>|
      \g<day>-\g<month>-\g<year>|
      \g<year>\g<month>|
      \g<year>/\g<month>|
      \g<year>-\g<month>|
      \g<month>\g<year>|
      \g<month>/\g<year>|
      \g<month>-\g<year>|
      \g<year>
    )\Z
  }x

  private

  def build_email_regexp(domain = nil)
    if domain.present?
      /#{EMAIL_REGEXP.source.split('@').first}@#{Regexp.escape(domain)}\z/
    else
      EMAIL_REGEXP
    end
  end
end
