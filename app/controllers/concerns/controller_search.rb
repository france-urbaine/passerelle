# frozen_string_literal: true

module ControllerSearch
  extend ActiveSupport::Concern

  def search(relation)
    relation = relation.search(params[:search]) if params[:search].present?
    relation
  end
end
