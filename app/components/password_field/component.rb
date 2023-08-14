# frozen_string_literal: true

module PasswordField
  class Component < ApplicationViewComponent
    def initialize(object_name, method, value = nil, strength_test: false, **options)
      @object_name   = object_name
      @method        = method
      @value         = value
      @strength_test = strength_test
      @options       = options
      super()
    end

    def options
      options = @options.dup

      if @object_name == :user && @method == :password
        options[:minlength] = Devise.password_length.min
        options[:maxlength] = Devise.password_length.max
      end

      if @strength_test
        options[:data] ||= {}
        options[:data][:action] = "strength-test#check"
      end

      options
    end

    def controller_options
      if @strength_test
        { data: { controller: "strength-test password-visibility" } }
      else
        { data: { controller: "password-visibility" } }
      end
    end
  end
end
