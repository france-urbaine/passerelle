# frozen_string_literal: true

module Views
  module Audits
    # @display frame "content"
    # @display width "medium"
    #
    class ListComponentPreview < ::Lookbook::Preview
      # @label Default
      #
      def default
        render_with_template(locals: { audits: random_audits })
      end

      # @label With pagination
      #
      def with_pagination
        render_with_template(locals: { audits: random_audits.first(pagy.items), pagy: pagy })
      end

      private

      def random_audits
        auditable = User.first
        timestamp = Time.now.utc
        user_ids = User.ids
        audits = []
        11.times do
          audits << Audit.new(
            created_at: timestamp,
            auditable: auditable,
            action: [
              AuditResolver::ACTION_CHANGE_ORGANIZATION,
              AuditResolver::ACTION_CHANGE_ORGANIZATION_AND_UPDATE,
              AuditResolver::ACTION_LOGIN,
              AuditResolver::ACTION_TWO_FACTORS,
              "update"
            ].sample,
            user: User.find(user_ids.sample)
          )
          timestamp -= rand(1..3600).second
        end

        audits << Audit.new(
          created_at: timestamp,
          auditable: auditable,
          action: "create",
          user: User.find(user_ids.sample)
        )
        audits
      end

      def pagy
        Pagy.new(count: 12, page: 1, items: 5)
      end
    end
  end
end
