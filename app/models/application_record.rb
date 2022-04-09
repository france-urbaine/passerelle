# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include Discard::Model
  include SkipUniquenessValidation

  primary_abstract_class

  self.abstract_class        = true
  self.implicit_order_column = :created_at

  SIREN_REGEXP = /\A[0-9]{9}\Z/
  EMAIL_REGEXP = URI::MailTo::EMAIL_REGEXP
end
