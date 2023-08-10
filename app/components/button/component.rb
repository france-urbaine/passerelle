# frozen_string_literal: true

module Button
  class Component < ApplicationViewComponent
    def initialize(*args, **options)
      raise ArgumentError, "wrong number of arguments (given #{args.size}, expected 0..2)" if args.size > 2

      @args    = args
      @options = options
      super()
    end

    def call
      extract_label_and_href
      extract_options

      if @href && (@method || @params)
        button_to { capture_html_content }
      elsif @href
        link { capture_html_content }
      else
        button { capture_html_content }
      end
    end

    protected

    def extract_label_and_href
      if content?
        case @args.size
        when 0
          @label = content
        when 1
          @label = content
          @href  = @args[0] || @options[:href]
        else
          raise ArgumentError, "Label can be specified as an argument or in a block, not both."
        end
      else
        @label = @args[0]
        @href  = @args[1] || @options[:href]
      end
    end

    def extract_options
      options = @options.dup
      options.delete(:href)

      @icon = options.delete(:icon)

      if options.key?(:icon_only)
        @icon_only = options.delete(:icon_only)
      elsif @icon && @label.blank?
        @icon_only = true
      end

      @method      = options.delete(:method)
      @params      = options.delete(:params).presence
      @modal       = options.delete(:modal)
      @primary     = options.delete(:primary)
      @accent      = options.delete(:accent)
      @destructive = options.delete(:destructive)
      @discrete    = options.delete(:discrete)
      @options     = options
    end

    def capture_html_content
      raise "Label is missing" if @label.nil? && @icon.nil?

      buffer = ActiveSupport::SafeBuffer.new
      buffer << icon if @icon
      buffer << @label if @label && !@icon_only
      buffer << tooltip if @icon_only && @label
      buffer
    end

    def button_to(&)
      options = @options.dup
      options[:class]  = extract_class_attributes
      options[:data]   = extract_data_attributes
      options[:aria]   = extract_aria_attributes
      options[:method] = @method
      options[:params] = @params
      options[:form_class] = ""

      helpers.button_to href, options, &
    end

    def link(&)
      options = @options.dup
      options[:class] = extract_class_attributes
      options[:data]  = extract_data_attributes
      options[:aria]  = extract_aria_attributes
      options[:href]  = href

      tag.a(**options, &)
    end

    def button(&)
      options = @options.dup
      options[:class] = extract_class_attributes
      options[:data]  = extract_data_attributes
      options[:aria]  = extract_aria_attributes
      options[:type] ||= "button"

      tag.button(**options, &)
    end

    def href
      ::UrlHelper.new(@href).join(href_params).to_s
    end

    def href_params
      {}
    end

    def icon
      if @icon_only && @label
        icon_component(@icon, @label)
      else
        icon_component(@icon)
      end
    end

    def tooltip
      return unless @label

      tag.span(class: "tooltip") { @label }
    end

    # Safelisting all classes to let Tailwind knowns what classes are used.
    #
    BUTTON_CLASSES = %w[
      icon-button
      icon-button--primary
      icon-button--accent
      icon-button--destructive
      button
      button--primary
      button--accent
      button--destructive
      button--primary-discrete
      button--accent-discrete
      button--destructive-discrete
    ].freeze

    def extract_class_attributes
      classes = @options.fetch(:class, "")

      if @icon_only
        classes += " icon-button"
        classes += " icon-button--#{button_class_modifier}" if button_class_modifier
      else
        classes += " button"
        classes += " button--#{button_class_modifier}" if button_class_modifier
      end

      classes.strip
    end

    def button_class_modifier
      if @primary == "discrete"
        "primary-discrete"
      elsif @primary
        "primary"
      elsif @accent == "discrete"
        "accent-discrete"
      elsif @accent
        "accent"
      elsif @destructive == "discrete"
        "destructive-discrete"
      elsif @destructive
        "destructive"
      end
    end

    def extract_data_attributes
      data = @options.fetch(:data, {})
      data[:turbo_frame] = "modal" if @href && @modal
      data
    end

    def extract_aria_attributes
      aria = @options.fetch(:aria, {})
      aria[:label] ||= @label if @icon_only && @label
      aria
    end
  end
end
