# frozen_string_literal: true

class ApplicationPolicy < ActionPolicy::Base
  # ActionPolicy::Base is already defining the following rules:
  #   default_rule :manage?
  #   alias_rule :new?, to: :create?
  #
  #   def index? = false
  #   def create? = false
  #   def manage? = false
  #
  alias_rule :remove_all?, to: :destroy_all?
  alias_rule :edit_all?, to: :update_all?

  def destroy_all?
    false
  end

  def undiscard_all
    false
  end

  def update_all?
    false
  end

  # Add predicates to check permissions
  #
  delegate :organization, to: :user, allow_nil: true

  protected

  # Common predicates to identify which kind of user is used
  #
  def user?
    user.present?
  end

  def organization_admin?
    user? && user.organization_admin?
  end

  def super_admin?
    user? && user.super_admin?
  end

  def collectivity?
    organization.is_a?(Collectivity)
  end

  def publisher?
    organization.is_a?(Publisher)
  end

  def ddfip?
    organization.is_a?(DDFIP)
  end

  def collectivity_admin?
    collectivity? && organization_admin?
  end

  def publisher_admin?
    publisher? && organization_admin?
  end

  def ddfip_admin?
    ddfip? && organization_admin?
  end

  def office_user?
    ddfip? && !organization_admin?
  end
end
