# frozen_string_literal: true

module UI
  module Form
    module PasswordField
      class Component < ApplicationViewComponent
        define_component_helper :password_field_component

        def initialize(object_name, method, value = nil, strength_test: false, **options)
          @object_name   = object_name
          @method        = method
          @value         = value
          @strength_test = strength_test
          @options       = options
          super()
        end

        def input_html_attributes
          options = @options.dup

          if @object_name == :user && @method == :password
            options[:minlength] = Devise.password_length.min
            options[:maxlength] = Devise.password_length.max
          end

          options[:data] ||= { action: "" }
          options[:data][:password_visibility_target] = "input"
          options[:data][:action] += " strength-test#check" if @strength_test
          options
        end

        def wrapper_html_attributes
          attributes = {
            class: "password-field",
            data: { controller: "password-visibility" }
          }

          attributes[:data][:controller] += " strength-test" if @strength_test
          attributes
        end
      end
    end
  end
end
