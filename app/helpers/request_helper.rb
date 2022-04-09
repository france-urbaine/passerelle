# frozen_string_literal: true

module RequestHelper
  def extract_params(*keys)
    keys = keys.flatten
    params.slice(*keys).permit!
  end
end
