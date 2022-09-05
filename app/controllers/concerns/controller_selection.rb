# frozen_string_literal: true

module ControllerSelection
  extend ActiveSupport::Concern

  def select(relation)
    case params[:ids]
    when "all" then relation
    when Array then relation.where(id: params[:ids])
    else
      raise ActionController::UnpermittedParameters, %i[ids]
    end
  end
end
