# frozen_string_literal: true

module FormHelper
  class FormBuilder < ActionView::Helpers::FormBuilder
    def block(method, **options, &)
      @template.form_block(@object, method, **options, &)
    end

    def errors(method)
      @template.form_block(@object, method)
    end
  end

  def back_param_input
    return unless params.key?(:back)

    tag.input(type: "hidden", name: "back", value: params[:back])
  end

  def form_block(record, attribute, first: false, autocomplete: false, **options, &block)
    options[:class] = Array.wrap(options[:class])
    options[:class] << "form-block"
    options[:class] << "form-block--margin" unless first
    options[:class] << "form-block--invalid" if record.errors.include?(attribute)

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
