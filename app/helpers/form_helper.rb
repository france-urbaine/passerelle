# frozen_string_literal: true

module FormHelper
  class FormBuilder < ActionView::Helpers::FormBuilder
    def block(method, **options, &)
      @template.form_block(@object, method, **options, &)
    end

    def errors(method)
      @template.display_errors(@object, method)
    end

    def checkboxes_component(method, collection, value_method, text_method, options = {}, html_options = {})
      @template.checkboxes_component(
        @object_name,
        method,
        collection,
        value_method,
        text_method,
        objectify_options(options),
        @default_html_options.merge(html_options)
      )
    end
  end

  def hidden_param_input(key, &)
    return unless params.key?(key)

    if block_given?
      each_hidden_param_field_tag(key, params[key], &)
    else
      buffer = []
      each_hidden_param_field_tag(key, params[key]) do |input|
        buffer << input
      end
      safe_join buffer
    end
  end

  def each_hidden_param_field_tag(name, value, &)
    return to_enum(:each_hidden_param_field_tag, name, value) unless block_given?

    case value
    when Array
      value.each do |item|
        each_hidden_param_field_tag("#{name}[]", item, &)
      end
    when Hash, ActionController::Parameters
      value.each do |key, item|
        each_hidden_param_field_tag("#{name}[#{key}]", item, &)
      end
    else
      yield tag.input(type: "hidden", name: name, value: value, autocomplete: "off")
    end
  end

  def form_block(record, attribute, first: false, autocomplete: false, **options, &block)
    options[:class] = Array.wrap(options[:class])
    options[:class] << "form-block"
    options[:class] << "form-block--margin" unless first
    options[:class] << "form-block--invalid" if record.respond_to?(:errors) && record.errors.include?(attribute)

    options[:data] ||= {}

    if autocomplete
      options[:class] << "hidden autocomplete"
      options[:data][:controller] = "autocomplete"
      options[:data][:autocomplete_url_value] = autocomplete
      options[:data][:autocomplete_selected_class] = "autocomplete__list-item--active"
    end

    tag.div(**options) do
      concat capture(&block)
      concat display_errors(record, attribute)
      concat autocomplete_results if autocomplete
    end
  end

  def display_errors(record, attribute)
    return unless record.respond_to?(:errors)

    capture do
      record.errors.messages_for(attribute).each do |error|
        concat tag.div(error, class: "form-block__errors")
      end
    end
  end

  def autocomplete_results
    tag.div class: "autocomplete__list-wrapper" do
      tag.ul class: "autocomplete__list", data: { autocomplete_target: "results" }
    end
  end
end
