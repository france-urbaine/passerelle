# frozen_string_literal: true

# Adapted from yaaf gem:
# https://github.com/rootstrap/yaaf/blob/4531200021fbe3c77df46f3290134dbf4bcdc71d/lib/yaaf/form.rb
#
class FormService
  include ::ActiveModel::Model
  include ::ActiveModel::Validations::Callbacks
  include ::ActiveRecord::Transactions

  define_model_callbacks :save
  delegate :transaction, to: ::ActiveRecord::Base
  validate :validate_record

  def initialize(record, attributes = {})
    @record = record
    super(attributes)
  end

  def save(...)
    save_form(...)
    build_result
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved, ActiveModel::ValidationError
    build_result
  end

  def save!(...)
    save_form(...)
    build_result
  end

  def respond_to_missing?(method, *)
    missing_attribute_method?(method)
  end

  def method_missing(method, *)
    return super unless missing_attribute_method?(method)

    record.public_send(method, *)
  end

  private

  attr_accessor :record

  def save_form(**options)
    validate! unless options[:validate] == false

    run_callbacks :commit do
      save_in_transaction(**options)
    end

    true
  end

  def save_in_transaction(...)
    transaction do
      run_callbacks :save do
        save_record(...)
      end
    end
  rescue StandardError => e
    handle_transaction_rollback(e)
  end

  def save_record(**)
    record.save!(**, validate: false)
  end

  def validate_record
    errors.merge!(record.errors) if record.invalid?
  end

  def promote_errors(others)
    record.errors.merge!(others)
    errors.merge!(others)
  end

  def build_result
    if errors.empty?
      Result::Success.new(record)
    else
      Result::Failure.new(errors)
    end
  end

  def handle_transaction_rollback(exception)
    run_callbacks :rollback
    raise exception
  end

  def missing_attribute_method?(method)
    # This method allow to call any attribute method from the delegated model.
    # It also accepts nested attributes methods.
    #
    # By default, all attributes (and nested attributes) methods are delegated,
    # so there is no mass-assignement protection at this level.
    #
    # To protect against mass-assignement, you'd better have to filter attributes
    # at upper level, with policy for example.
    #

    # Match regular attibutes methods:
    #   name
    #   name=
    #   name?
    #
    return false unless method =~ /^([a-z]\w+)(=|\?)?$/
    return true  if record.class.column_names.include?(::Regexp.last_match(1))

    # Match nested attributes methods
    #   exonerations_attributes=
    #
    return false unless method =~ /^([a-z]\w+)_attributes=$/
    return true if record.class.nested_attributes_options.keys.map(&:to_s).include?(::Regexp.last_match(1))

    false
  end

  def self.alias_record(alias_name)
    alias_method alias_name, :record
  end

  private_class_method :alias_record
end
