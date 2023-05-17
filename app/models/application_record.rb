# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include Discard::Model
  include AdvancedDiscardable
  include AdvancedOrder
  include AdvancedSearch
  include ScoredOrder
  include SkipUniquenessValidation

  primary_abstract_class

  self.abstract_class        = true
  self.implicit_order_column = :created_at

  SIREN_REGEXP  = /\A[0-9]{9}\Z/
  PHONE_REGEXP  = /\A(0|\+(33|590|594|596|262|269))?[0-9]{9}\Z/
  EMAIL_REGEXP  = URI::MailTo::EMAIL_REGEXP
  DOMAIN_REGEXP = /\A[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*\z/

  CODE_REGION_REGEXP      = /\A[0-9]{2}\Z/
  CODE_DEPARTEMENT_REGEXP = /\A(2[AB]|[0-9]{2}|9[0-9]{2})\Z/
  CODE_INSEE_REGEXP       = /\A(2[AB]|[0-9]{2})[0-9]{3}\Z/

  private

  def build_email_regexp(domain  = nil)
    if domain.present?
      /\A[a-zA-Z0-9.!\#$%&'*+\/=?^_`{|}~-]+@#{Regexp.escape(domain)}\z/
    else
      EMAIL_REGEXP
    end
  end
end
