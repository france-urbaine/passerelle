# frozen_string_literal: true

module RadioButtons
  class Component < ApplicationViewComponent
    def initialize(object_name, method, collection, value_method: nil, text_method: nil, resettable: false, **options)
      @object_name  = object_name
      @method       = method
      @collection   = collection.to_a
      @value_method = value_method || default_input_methods[0]
      @text_method  = text_method || default_input_methods[1]

      @resettable   = resettable
      @options      = options
      @options[:include_hidden] = options.fetch(:include_hidden, false) if resettable

      super()
    end

    def default_input_methods
      case @collection
      in [ApplicationRecord, *]
        if @collection.first.respond_to?(:name)
          %i[id name]
        else
          %i[id to_s]
        end
      in [Array, *]
        %i[first second]
      else
        %i[to_s to_s]
      end
    end

    def reset_field_name
      @reset_field_name ||= field_name(@object_name, @method)
    end

    def reset_field_id
      # Copied from Rails private method: FormTagHelper#sanitize_to_id
      # Rails doesn't properly set the 'for' attribute on the label when the value is blank
      #
      @reset_field_id ||= reset_field_name.to_s.delete("]").tr("^-a-zA-Z0-9:.", "_").gsub(/_?$/, "_reset")
    end

    def radio_button_reset_tag
      radio_button(reset_field_name, "", false, id: reset_field_id)
    end

    def label_reset_tag
      label = @resettable.is_a?(String) ? @resettable : "Annuler l'option saisie"

      label_tag(reset_field_name, label, for: reset_field_id)
    end
  end
end
