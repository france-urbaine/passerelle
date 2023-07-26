# frozen_string_literal: true

class InflectionsOptions
  attr_reader :singular, :plural

  def self.new(*args, **kwargs)
    super if args.compact.any? || kwargs.any?
  end

  def initialize(argument = nil, singular: nil, plural: nil)
    validate_arguments!(argument, singular)

    if argument.is_a?(InflectionsOptions)
      @singular = argument.singular
      @plural   = argument.plural
    elsif argument.respond_to?(:model_name)
      @singular = initialize_with_model(argument)
      @plural   = @singular.pluralize
    else
      @singular = argument || singular
      @plural   = plural || @singular.pluralize
    end
  end

  private

  def validate_arguments!(argument, singular)
    raise ArgumentError, "use argument or keyword arguments, not both" if argument && singular
    raise ArgumentError, "argument missing" if argument.nil? && singular.nil?
  end

  def initialize_with_model(model)
    result = model.model_name.human.downcase!
    ActiveSupport::Inflector.inflections.acronyms[result] || result
  end
end
