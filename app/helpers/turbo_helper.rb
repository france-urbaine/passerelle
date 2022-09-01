# frozen_string_literal: true

module TurboHelper
  def render_turbo_stream_notifications(notification)
    turbo_stream.prepend :notifications do
      render(NotificationComponent.new(notification))
    end
  end

  def update_turbo_stream_content_from(location)
    turbo_stream.replace :content do
      turbo_frame_tag :content, src: location
    end
  end

  def clear_turbo_stream_modal
    turbo_stream.update :modal, ""
  end
end
