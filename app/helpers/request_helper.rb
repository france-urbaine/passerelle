# frozen_string_literal: true

module RequestHelper
  def extract_params(*keys)
    params.slice(*keys.flatten).permit!
  end

  def current_path
    request.fullpath
  end

  INDEX_PARAMS = %i[search order page].freeze

  def current_index_params
    extract_params(*INDEX_PARAMS)
  end

  def current_index_back_params
    index_params = current_index_params

    if index_params.empty?
      {}
    else
      { index: index_params }
    end
  end

  def retrieve_index_back_params
    params.fetch(:index, {}).slice(*INDEX_PARAMS).permit!
  end
end
