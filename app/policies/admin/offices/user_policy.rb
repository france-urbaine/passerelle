# frozen_string_literal: true

module Admin
  module Offices
    class UserPolicy < ::Admin::UserPolicy
      alias_rule :show?, :edit?, :update?, :undiscard?, :undiscard_all?, to: :not_supported
      alias_rule :edit_all?, :update_all?, to: :manage?
    end
  end
end
