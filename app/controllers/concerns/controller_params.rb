# frozen_string_literal: true

module ControllerParams
  private

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

  def redirect_back_path
    redirect_path || referrer_path
  end

  def after_destroy_path(default:)
    path = default
    path = ::UrlHelper.new(path).base

    path.join(selection_params.except(:ids)).to_s
  end

  def after_destroy_all_path(default:)
    path = referrer_path || default
    path = ::UrlHelper.new(path).base

    return path if params[:ids] == "all"

    path.join(selection_params.except(:ids)).to_s
  end
end
