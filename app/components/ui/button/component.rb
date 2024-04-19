# frozen_string_literal: true

module UI
  module Button
    class Component < ApplicationViewComponent
      define_component_helper :button_component

      def initialize(*args, **kwargs)
        raise ArgumentError, "wrong number of arguments (given #{args.size}, expected 0..2)" if args.size > 2

        @args   = args
        @kwargs = kwargs
        super()
      end

      def before_render
        extract_label_and_href
        extract_options
      end

      def call
        if @href && (@options[:method] || @options[:params])
          render_single_form_button
        elsif @href
          render_link
        else
          render_button
        end
      end

      protected

      def extract_label_and_href
        if content?
          case @args.size
          when 0
            @label = content
            @href  = nil
          when 1
            @label = content
            @href  = @args[0] || @kwargs[:href]
          else
            raise ArgumentError, "Label can be specified as an argument or in a block, not both."
          end
        else
          @label = @args[0]
          @href  = @args[1] || @kwargs[:href]
        end
      end

      def extract_options
        options = @kwargs.dup
        options.delete(:href)

        @icon          = options.delete(:icon)
        @icon_options  = options.delete(:icon_options)
        @icon_position = options.delete(:icon_position)

        if options.key?(:icon_only)
          @icon_only = options.delete(:icon_only)
        elsif @icon && @label.blank?
          @icon_only = true
        end

        @modal       = options.delete(:modal)
        @primary     = options.delete(:primary)
        @accent      = options.delete(:accent)
        @destructive = options.delete(:destructive)
        @discrete    = options.delete(:discrete)
        @options     = options
      end

      def render_single_form_button
        options = reverse_merge_attributes(@options, {
          class:      class_attributes,
          data:       { turbo_frame: },
          aria:       { label: aria_label },
          method:     "get",
          form_class: "#{base_class}-form"
        })

        warn_about_turbo_frame_conflict(options)

        helpers.button_to(@href, options) { render_content }
      end

      def render_link
        options = reverse_merge_attributes(@options, {
          href:   @href,
          class:  class_attributes,
          data:   { turbo_frame: },
          aria:   { label: aria_label }
        })

        warn_about_turbo_frame_conflict(options)

        tag.a(**options) { render_content }
      end

      def render_button
        options = reverse_merge_attributes(@options, {
          type:   "button",
          class:  class_attributes,
          aria:   { label: aria_label }
        })

        tag.button(**options) { render_content }
      end

      def render_content
        raise "Label is missing" if @label.nil? && @icon.nil?

        buffer = ActiveSupport::SafeBuffer.new
        buffer << leading_icon
        buffer << text
        buffer << trailing_icon
        buffer << tooltip
      end

      def text
        @label if @label && !@icon_only
      end

      def icon
        icon_options = @icon_options || {}

        if @icon_only && @label
          icon_component(@icon, @label, **icon_options)
        else
          icon_component(@icon, **icon_options)
        end
      end

      def leading_icon
        icon if @icon && @icon_position != "end"
      end

      def trailing_icon
        icon if @icon && @icon_position == "end"
      end

      def tooltip
        tag.span(class: "tooltip") { @label } if @icon_only && @label
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
        button--trailing-icon
      ].freeze

      def class_attributes
        css_class = base_class
        css_class += " #{base_class}--#{button_class_modifier}" if button_class_modifier
        css_class += " #{base_class}--trailing-icon" if @icon && @icon_position == "end"
        css_class
      end

      def base_class
        if @icon_only
          "icon-button"
        else
          "button"
        end
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

      def turbo_frame
        "modal" if @href && @modal
      end

      def warn_about_turbo_frame_conflict(options)
        return unless turbo_frame == "modal" && options.dig(:data, :turbo_frame) != "modal"

        Rails.logger.warn(<<~MESSAGE.squish)
          the button gets the arguments `modal: true`
          and `turbo_frame: #{options.dig(:data, :turbo_frame).inspect}`:
          the first one is ignored.
        MESSAGE
      end

      def aria_label
        @label if @icon_only && @label
      end
    end
  end
end
