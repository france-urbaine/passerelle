# frozen_string_literal: true

class SearchComponentPreview < ViewComponent::Preview
  # @!group Default
  def default
    render(SearchComponent.new)
  end

  # @param label
  def with_dynamic_label(label: "Rechercher des objets")
    render(SearchComponent.new(label: label))
  end
  # @!endgroup
end
