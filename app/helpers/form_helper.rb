# frozen_string_literal: true

module FormHelper
  def back_param_input
    return unless params.key?(:back)

    tag.input(type: "hidden", name: "back", value: params[:back])
  end

  def form_block(record, attribute, &)
    classes = %w[form-block]
    classes << "form-block--invalid" if record.errors.include?(attribute)

    tag.div class: classes do
      concat capture(&)
      concat display_errors(record, attribute)
    end
  end

  def display_errors(record, attribute)
    capture do
      record.errors.messages_for(attribute).each do |error|
        concat tag.div(error, class: "form-block__errors")
      end
    end
  end
end
