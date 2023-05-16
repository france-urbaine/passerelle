# frozen_string_literal: true

require "English"

module SkipUniquenessValidation
  extend ActiveSupport::Concern

  included do
    attr_accessor :skip_uniqueness_validation
  end

  def skip_uniqueness_validation!
    @skip_uniqueness_validation = true
  end

  def skip_uniqueness_validation?
    @skip_uniqueness_validation
  end

  def skip_uniqueness_validation_of_attribute?(attribute)
    return true if @skip_uniqueness_validation

    return false if will_save_change_to_attribute?(:discarded_at, to: nil)
    return true  if respond_to?(:discarded?) && discarded?

    return true if persisted? && !will_save_change_to_attribute?(attribute)

    false
  end

  def respond_to_missing?(method, *)
    respond_to_skip_uniqueness_validation_method?(method) || super
  end

  def method_missing(method, *)
    if (attribute = respond_to_skip_uniqueness_validation_method?(method))
      skip_uniqueness_validation_of_attribute?(attribute)
    else
      super
    end
  end

  private

  METHOD_PATTERN = /^skip_uniqueness_validation_of_(.+)\?$/

  def respond_to_skip_uniqueness_validation_method?(method)
    method.match(METHOD_PATTERN) && self.class.column_names.include?($LAST_MATCH_INFO[1]) && $LAST_MATCH_INFO[1]
  end
end
