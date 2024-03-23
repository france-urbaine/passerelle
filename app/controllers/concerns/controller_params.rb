# frozen_string_literal: true

module ControllerParams
  private

  def search_param
    params[:search]
  end

  def order_param
    params[:order]
  end

  def selection_params
    params
      .slice(:search, :order, :page, :ids)
      .permit(:search, :order, :page, :ids, ids: [])
  end

  def referrer_path
    url_from(params[:referrer] || request.referer)
  end

  def redirect_path
    url_from(params[:redirect])
  end
end
