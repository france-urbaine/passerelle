# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include Discard::Model
  include AdvancedOrder
  include AdvancedSearch
  include ScoredOrder
  include SkipUniquenessValidation

  primary_abstract_class

  self.abstract_class        = true
  self.implicit_order_column = :created_at

  SIREN_REGEXP = /\A[0-9]{9}\Z/
  EMAIL_REGEXP = URI::MailTo::EMAIL_REGEXP
  PHONE_REGEXP = /\A(0|\+(33|590|594|596|262|269))?[0-9]{9}\Z/

  CODE_REGION_REGEXP      = /\A[0-9]{2}\Z/
  CODE_DEPARTEMENT_REGEXP = /\A(2[AB]|[0-9]{2}|9[0-9]{2})\Z/
  CODE_INSEE_REGEXP       = /\A(2[AB]|[0-9]{2})[0-9]{3}\Z/

  scope :discarded_over, ->(duration) { discarded.where("discarded_at < ?", duration.ago) }
end
