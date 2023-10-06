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
  alias_rule :remove_all?, :destroy_all?, :undiscard_all?, to: :not_supported
  alias_rule :edit_all?, :update_all?, to: :not_supported

  def not_supported
    false
  end

  # Add predicates to check permissions
  #
  delegate :organization, to: :user, allow_nil: true

  protected

  # Common predicates to identify which kind of user is used
  #
  def user?
    !user.nil?
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

  def dgfip?
    organization.is_a?(DGFIP)
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

  def dgfip_admin?
    dgfip? && organization_admin?
  end

  def office_user?
    ddfip? && !organization_admin?
  end
end
