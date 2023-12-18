# frozen_string_literal: true

module Organization
  module OauthApplications
    class AuditPolicy < ApplicationPolicy
      def index?
        publisher?
      end

      relation_scope do |relation|
        return relation.none unless publisher?

        relation.where(oauth_application_id: organization.oauth_application_ids)
      end
    end
  end
end
