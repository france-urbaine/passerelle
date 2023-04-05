# frozen_string_literal: true

module ControllerParams
  private

  def referrer_path
    url_from(params[:referrer])
  end

  def redirect_path
    url_from(params[:redirect])
  end

  def selection_params
    params
      .slice(:search, :order, :page, :ids)
      .permit(:search, :order, :page, ids: [])
  end
end
