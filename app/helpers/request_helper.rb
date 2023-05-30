# frozen_string_literal: true

module RequestHelper
  def extract_params(*keys)
    params.slice(*keys.flatten).permit!
  end

  def current_path
    request.fullpath
  end
end
