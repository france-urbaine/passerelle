# frozen_string_literal: true

module ControllerCollections
  include Pagy::Backend
  include ControllerParams

  NESTED_PAGE_LIMIT = 10

  private

  def index_collection(relation, nested: false, limit: nil)
    return autocomplete_collection(relation), nil if autocomplete_request?

    relation = search_collection(relation)
    relation = order_collection(relation)

    if nested
      paginate_collection(relation, limit: NESTED_PAGE_LIMIT)
    else
      paginate_collection(relation, limit:)
    end
  end

  def search_collection(relation, query: search_param)
    advanced_search_records(relation, query)
  end

  def order_collection(relation, order: order_param, query: search_param)
    relation = relation.order_by_param(order) if order.present?
    relation = relation.order_by_score(query) if query.present?
    relation = relation.order(relation.implicit_order_column) if relation.respond_to?(:implicit_order_column)
    relation
  end

  def paginate_collection(collection, limit: nil)
    # We memoize the pagination limit into session and to use the same settings
    # on every pagination.
    # The pagination limit can be reinitialized from params.
    #
    # We don't memoize the pagination limit when it's explicitely defined.
    # (in nested turbo frames, for example).
    #
    if limit
      pagy, relation = pagy(collection, limit:)
    else
      limit = session[:limit] if session[:limit] && !params.key?(:limit)
      pagy, relation = pagy(collection, limit:)
      session[:limit] = pagy.limit unless pagy.limit.zero?
    end

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

  def better_view_on_parent
    redirect_to(@parent, status: :see_other) if @parent && !turbo_frame_request?
  end
end
