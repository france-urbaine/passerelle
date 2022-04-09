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

  def skip_uniqueness_validation_of?(attribute)
    @skip_uniqueness_validation || (persisted? && !attribute_changed?(attribute))
  end

  def respond_to_missing?(method, *)
    respond_to_skip_uniqueness_validation_method?(method) || super
  end

  def method_missing(method, *)
    if (attribute = respond_to_skip_uniqueness_validation_method?(method))
      skip_uniqueness_validation_of?(attribute)
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
