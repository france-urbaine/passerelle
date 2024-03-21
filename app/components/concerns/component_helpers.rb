# frozen_string_literal: true

module ComponentHelpers
  extend ActiveSupport::Concern

  included do
    extend DefineMethods if is_a?(Class)
  end

  def self.eager_load
    Rails.autoloaders.main.eager_load_dir(File.expand_path("..", __dir__))
  end

  def self.add_component_helper(method_name, component_class_name)
    helper_module = Module.new do
      define_method method_name do |*args, **kwargs, &block|
        render component_class_name.constantize.new(*args, **kwargs), &block
      end
    end

    ComponentHelpers.prepend helper_module
  end

  module DefineMethods
    private

    def define_component_helper(method_name)
      ComponentHelpers.add_component_helper(method_name, name)
    end
  end
end
