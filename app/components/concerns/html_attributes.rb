# frozen_string_literal: true

module HTMLAttributes
  def parse_html_attributes(**html_attributes)
    if html_attributes[:id] == true
      @component_dom_id = html_attributes[:id] = generate_random_dom_id
    elsif html_attributes[:id].present?
      @component_dom_id = html_attributes[:id]
    end

    html_attributes
  end

  def merge_attributes(default, other)
    attributes         = default.merge(other)
    attributes[:class] = merge_class_attribute(default[:class], other[:class]) if default[:class]
    attributes[:aria]  = merge_aria_attribute(default[:aria], other[:aria])    if default[:aria]
    attributes[:data]  = merge_data_attribute(default[:data], other[:data])    if default[:data]
    attributes
  end

  def merge_attributes!(default, other)
    default.merge!(merge_attributes(default, other))
  end

  def reverse_merge_attributes(current, other)
    merge_attributes(other, current)
  end

  def reverse_merge_attributes!(current, other)
    current.merge!(reverse_merge_attributes(current, other))
  end

  protected

  def merge_class_attribute(default, other)
    merge_string_attribute(default, other)
  end

  def merge_aria_attribute(default, other)
    default ||= {}
    other   ||= {}

    default.merge(other)
  end

  def merge_data_attribute(default, other)
    default ||= {}
    other   ||= {}

    data = default.merge(other)
    data[:controller] = merge_string_attribute(default[:controller], other[:controller]) if default[:controller]
    data[:action]     = merge_string_attribute(default[:action],     other[:action])     if default[:action]
    data
  end

  private

  def merge_string_attribute(default, other)
    [default, other].flatten.join(" ").squish
  end
end
