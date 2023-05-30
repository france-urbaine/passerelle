# frozen_string_literal: true

class OrganizationsPolicy < ApplicationPolicy
  def index?
    super_admin?
  end
end
