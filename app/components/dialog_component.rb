# frozen_string_literal: true

class DialogComponent < ViewComponent::Base
  attr_reader :back_url

  def initialize(back_url: nil)
    @back_url = back_url
  end

  def close_button
    tag.a(
      href:  back_url,
      class: "icon-button dialog__close-button",
      data:  { turbo_action: "restore", action: "dialog#close" }
    ) do
      helpers.svg_icon("x-icon", "Fermer cette fenêtre")
    end
  end

  def cancel_button(label)
    tag.a(
      href:  back_url,
      class: "button",
      data:  { turbo_action: "restore", action: "dialog#close" }
    ) do
      label
    end
  end
end
