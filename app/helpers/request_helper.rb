# frozen_string_literal: true

module RequestHelper
  def extract_params(*keys)
    params.slice(*keys.flatten).permit!
  end

  def current_path
    request.fullpath
  end

  INDEX_BACK_PARAMS = %i[search order page].freeze

  def current_index_back_params
    back_params = extract_params(*INDEX_BACK_PARAMS)

    if back_params.empty?
      {}
    else
      { index: back_params }
    end
  end

  def retrieve_index_back_params
    params.fetch(:index, {}).slice(*INDEX_BACK_PARAMS).permit!
  end
end
