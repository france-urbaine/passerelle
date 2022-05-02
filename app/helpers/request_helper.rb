# frozen_string_literal: true

module RequestHelper
  def current_path
    request.fullpath
  end

  def back_param_input
    return unless params.key?(:back)

    tag.input(type: "hidden", name: "back", value: params[:back])
  end
end
