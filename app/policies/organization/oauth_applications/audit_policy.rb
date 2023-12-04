# frozen_string_literal: true

module Organization
  module OauthApplications
    class AuditPolicy < ApplicationPolicy
      def index?
        super_admin? || publisher_admin?
      end

      relation_scope do |relation|
        return relation.none if !super_admin? && !publisher?

        if super_admin?
          relation
        else
          relation.where(publisher: organization)
        end
      end
    end
  end
end
