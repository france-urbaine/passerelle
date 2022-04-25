# frozen_string_literal: true

module ControllerSearch
  extend ActiveSupport::Concern

  def search(relation)
    relation = relation.search(search_params) if search_params
    relation
  end

  def search_params
    if params[:search].present?
      params[:search]
    elsif params[:q].present?
      params[:q]
    end
  end
end
