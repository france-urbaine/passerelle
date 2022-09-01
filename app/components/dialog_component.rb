# frozen_string_literal: true

class DialogComponent < ViewComponent::Base
  def close_button(**options)
    tag.a(
      **options,
      class: "icon-button dialog__close-button",
      aria:  { label: "Fermer la fenêtre de dialogue" },
      data:  { action: "dialog#close" }
    ) do
      helpers.svg_icon("x-icon", "Fermer cette fenêtre")
    end
  end

  def cancel_button(label, **options)
    tag.a(
      **options,
      class: "button",
      data:  { action: "dialog#close" }
    ) do
      label
    end
  end
end
