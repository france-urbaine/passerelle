# frozen_string_literal: true

module RequestHelper
  def extract_params(*keys)
    params.slice(*keys.flatten).permit!
  end

  def current_path
    request.fullpath
  end

  def back_param_input
    return unless params.key?(:back)

    tag.input(type: "hidden", name: "back", value: params[:back])
  end
end
