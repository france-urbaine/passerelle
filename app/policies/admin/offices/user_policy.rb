# frozen_string_literal: true

module Admin
  module Offices
    class UserPolicy < ::Admin::UserPolicy
      alias_rule :edit_all?, :update_all?, to: :manage?
    end
  end
end
