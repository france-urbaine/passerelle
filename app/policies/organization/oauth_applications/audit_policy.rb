# frozen_string_literal: true

module Organization
  module OauthApplications
    class AuditPolicy < ApplicationPolicy
      def index?
        publisher?
      end

      relation_scope do |relation|
        return relation.none unless publisher?

        relation.where(publisher: organization)
      end
    end
  end
end
