# frozen_string_literal: true

class ButtonComponent < ViewComponent::Base
  def initialize(label = nil, href = nil, **options)
    @label = label
    @href = href || options.delete(:href)
    @icon = options.delete(:icon)
    @icon_only = options.delete(:icon_only)
    @modal = options.delete(:modal)
    @primary = options.delete(:primary)
    @destructive = options.delete(:destructive)
    @options = options
    super()
  end

  def call
    label   = capture_label unless @icon_only
    content = capture_content(label)

    if @href
      link(icon_only: !label) { content }
    else
      button(icon_only: !label) { content }
    end
  end

  protected

  def capture_label
    raise "Label can be specified as an argument or in a block, not both." if @label && content.present?

    @label || content
  end

  def capture_content(label)
    raise "Label is missing" if label.nil? && @icon.nil?

    buffer = ActiveSupport::SafeBuffer.new
    buffer << icon if @icon
    buffer << label
    buffer << tooltip if @icon_only && @label
    buffer
  end

  def link(icon_only: false, &)
    options = @options.dup
    options[:class] = extract_class_attributes(icon_only:)
    options[:data]  = extract_data_attributes
    options[:aria]  = extract_aria_attributes
    options[:href]  = @href

    tag.a(**options, &)
  end

  def button(icon_only: false, &)
    options = @options.dup
    options[:class] = extract_class_attributes(icon_only:)
    options[:data]  = extract_data_attributes
    options[:aria]  = extract_aria_attributes
    options[:type] ||= "button"

    tag.button(**options, &)
  end

  def icon
    if @icon_only && @label
      helpers.svg_icon(@icon, @label)
    else
      helpers.svg_icon(@icon)
    end
  end

  def tooltip
    return unless @label

    tag.span(class: "tooltip") { @label }
  end

  def extract_class_attributes(icon_only: false)
    classes = @options.fetch(:class, "")

    if icon_only
      classes += " icon-button"
      classes += " icon-button--primary" if @primary
      classes += " icon-button--destructive" if @destructive
    else
      classes += " button"
      classes += " button--primary" if @primary
      classes += " button--destructive" if @destructive
    end

    classes.strip
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
