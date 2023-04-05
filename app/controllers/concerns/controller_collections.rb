# frozen_string_literal: true

module ControllerCollections
  include Pagy::Backend

  private

  def index_collection(relation)
    relation = search_collection(relation)
    relation = order_collection(relation)
    paginate_collection(relation)
  end

  def search_collection(relation)
    relation = relation.search(params[:search]) if params[:search]
    relation = relation.search(params[:q]) if params[:q]
    relation
  end

  def order_collection(relation)
    relation = relation.order_by_param(params[:order]) if params[:order].present?
    relation = relation.order_by_score(params[:search]) if params[:search].present?
    relation = relation.order(relation.implicit_order_column) if relation.respond_to?(:implicit_order_column)
    relation
  end

  def paginate_collection(collection, options = {})
    options[:items] = session[:items] if session[:items] && !params.key?(:items)

    pagy, relation = pagy(collection, options)
    session[:items] = pagy.items unless pagy.items.zero?

    [relation, pagy]
  end

  def filter_collection(relation)
    return relation.none if params[:ids].blank?

    relation = search_collection(relation)

    case params[:ids]
    when "all" then relation
    when Array then relation.where(id: params[:ids])
    else
      raise ActionController::UnpermittedParameters, %i[ids]
    end
  end
end
