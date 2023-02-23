# frozen_string_literal: true

class ButtonComponent < ViewComponent::Base

  def initialize(label = nil, **options)
    @label = label
    @href = options.delete(:href)
    @icon = options.delete(:icon)
    @modal = options.delete(:modal)
    @primary = options.delete(:primary)
    @destructive = options.delete(:destructive)
    @options = options
    super()
  end

  def label
    @label || content
  end

  def call
    if @href
      link_to @href, **link_options do
        concat helpers.svg_icon(@icon) if @icon
        concat label
      end
    else
      content_tag :button, **button_options do
        concat helpers.svg_icon(@icon) if @icon
        concat label
      end
    end
  end

  def link_options
    options = button_options
    options[:data][:turbo_frame] = "modal" if @modal
    options
  end

  def button_options
    options = @options.dup

    options[:data] ||= {}

    options[:class] ||= ""
    options[:class] += " #{base_class}"
    options[:class] += " #{base_class}--primary" if @primary
    options[:class] += " #{base_class}--destructive" if @destructive

    options[:class] = options[:class].strip

    options
  end

  # Tell taiwind to keep these CSS classes and not be purged
  #
  KEEP_THESE_CLASSES = %w[
    button--primary
    button--destructive
    icon-button--primary
    icon-button--destructive
  ].freeze

  def base_class
    @base_class ||=
      if @icon && label.blank?
        "icon-button"
      else
        "button"
      end
  end
end
