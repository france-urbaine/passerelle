# frozen_string_literal: true

module API
  class ApplicationPolicy < ActionPolicy::Base
    authorize :user, allow_nil: true
    authorize :publisher

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
  end
end
