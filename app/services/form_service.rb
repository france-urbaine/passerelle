# frozen_string_literal: true

# Adapted from yaaf gem:
# https://github.com/rootstrap/yaaf/blob/4531200021fbe3c77df46f3290134dbf4bcdc71d/lib/yaaf/form.rb
#
class FormService
  class Result
    attr_reader :models, :errors

    def initialize(models, errors)
      @models = models
      @errors = errors
    end

    def failed?
      @errors.any?
    end

    def success?
      !failed?
    end
  end

  include ::ActiveModel::Model
  include ::ActiveModel::Validations::Callbacks
  include ::ActiveRecord::Transactions

  define_model_callbacks :save
  delegate :transaction, to: ::ActiveRecord::Base
  validate :validate_models

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

  private

  attr_accessor :models

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
        save_models(...)
      end
    end
  rescue StandardError => e
    handle_transaction_rollback(e)
  end

  def save_models(**options)
    models.map do |model|
      model.save!(**options, validate: false)
    end
  end

  def validate_models
    models.each do |model|
      promote_errors(model) if model.invalid?
    end
  end

  def promote_errors(model)
    errors.merge!(model.errors)
  end

  def build_result
    Result.new(models, errors)
  end

  def handle_transaction_rollback(exception)
    run_callbacks :rollback
    raise exception
  end
end
