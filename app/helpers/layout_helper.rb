# frozen_string_literal: true

module LayoutHelper
  def page_content(src: nil, &)
    content_for(:content_src, src) if src
    content_for(:content, &) if block_given?
    ""
  end

  def page_modal(&)
    if turbo_frame_request?
      turbo_frame_tag(:modal, &)
    else
      content_for(:modal, &)
      ""
    end
  end

  def page_content_frame_tag
    turbo_frame_tag "content", target: "_top", data: { turbo_action: "advance" }, src: content_for(:content_src) do
      content_for(:content)
    end
  end

  def page_modal_frame_tag
    turbo_frame_tag "modal", target: "_top", src: content_for(:modal_src) do
      content_for(:modal)
    end
  end
end
