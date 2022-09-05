# frozen_string_literal: true

module ControllerItems
  extend ActiveSupport::Concern

  def pagy(collection, options = {})
    options[:items] = session[:items] if session[:items] && !params.key?(:items)

    pagy, relation = super(collection, options)
    session[:items] = pagy.items unless pagy.items.zero?

    [pagy, relation]
  end
end
