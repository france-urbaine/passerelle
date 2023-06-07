# frozen_string_literal: true

class ApplicationPolicy < ActionPolicy::Base
  # ActionPolicy::Base is already defining the following rules:
  #   default_rule :manage?
  #   alias_rule :new?, to: :create?
  #
  #   def index? = false
  #   def create? = false
  #   def manage? = false
  alias_rule :destroy_all?, :remove_all?, :undiscard_all?, to: :manage_collection?
  alias_rule :edit_all?, :update_all?, to: :manage_collection?

  def manage_collection?
    false
  end

  # Add predicates to check permissions
  #
  delegate :organization, :organization_admin?, :super_admin?, to: :user

  def user?
    user.present?
  end
end
