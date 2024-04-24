# frozen_string_literal: true

module ComponentIdentifier
  JOIN = ActionView::RecordIdentifier::JOIN

  def component_dom_id(prefix = nil)
    @component_dom_id ||= generate_random_dom_id

    id = @component_dom_id
    id = "#{prefix}#{JOIN}#{id}".downcase if prefix
    id
  end

  def component_short_name
    self.class.name.gsub(/(::)?Component$/, "").demodulize
  end

  def component_param_key
    component_short_name.underscore
  end

  def generate_random_dom_id(prefix = component_param_key)
    id = SecureRandom.alphanumeric(6)
    id = "#{prefix}-#{id}" if prefix
    id.downcase
  end
end
