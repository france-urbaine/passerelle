# frozen_string_literal: true

class NotificationComponentPreview < ViewComponent::Preview
  def default
    render(NotificationComponent.new("Hello world !"))
  end

  # @!group Types
  def information
    render(NotificationComponent.new({
      type:  "information",
      title: "Hello world !"
    }))
  end

  def success
    render(NotificationComponent.new({
      type:  "success",
      title: "Congrats !"
    }))
  end

  def error
    render(NotificationComponent.new({
      type:  "error",
      title: "Something went wrong."
    }))
  end
  # @!endgroup

  # @!group Enhanced
  def description
    render(NotificationComponent.new({
      title:       "Hello world !",
      description: <<~MESSAGE
        Lorem ipsum dolor sit amet, consectetur adipiscing elit.\n
        Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
      MESSAGE
    }))
  end

  def actions
    render(NotificationComponent.new({
      title:       "Something went wrong.",
      actions:     {
        label:  "Annuler",
        url:    "",
        method: :get
      },
      description: <<~MESSAGE
        Lorem ipsum dolor sit amet, consectetur adipiscing elit.\n
        Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
      MESSAGE
    }))
  end
  # @!endgroup
end
