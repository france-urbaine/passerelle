# frozen_string_literal: true

class ReportPolicy < ApplicationPolicy
  def index?
    true
  end

  def create?
    organization.is_a?(Collectivity)
  end

  def manage?
    true
  end

  relation_scope do |relation|
    # TODO
    relation.available_to(organization)
  end

  params_filter do |params|
    # TODO
    params.permit!
  end
end
