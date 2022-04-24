# frozen_string_literal: true

module TurboHelper
  def reset_turbo_stream_content
    path = params.fetch(:back)
    return unless path

    turbo_stream.replace :content do
      turbo_frame_tag :content, src: path
    end
  end

  def reset_turbo_stream_modal
    turbo_stream.update :modal, ""
  end

  def render_turbo_stream_notifications(notification)
    turbo_stream.prepend :notifications do
      render(NotificationComponent.new(notification))
    end
  end
end
