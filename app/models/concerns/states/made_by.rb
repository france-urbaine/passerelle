# frozen_string_literal: true

module States
  module MadeBy
    extend ActiveSupport::Concern

    included do
      # Scopes
      # ----------------------------------------------------------------------------
      scope :made_through_publisher_api, -> { where.not(publisher_id: nil) }
      scope :made_through_web_ui,        -> { where(publisher_id: nil) }

      scope :made_by_collectivity, ->(collectivity) { where(collectivity: collectivity) }
      scope :made_by_publisher,    ->(publisher)    { where(publisher: publisher) }

      # Predicates
      # ----------------------------------------------------------------------------
      def made_through_publisher_api?
        publisher_id? || (new_record? && publisher)
      end

      def made_through_web_ui?
        publisher_id.nil? && (persisted? || !publisher)
      end

      def made_by_collectivity?(collectivity)
        (collectivity_id == collectivity.id) || (new_record? && collectivity == self.collectivity)
      end

      def made_by_publisher?(publisher)
        (publisher_id == publisher.id) || (new_record? && publisher == self.publisher)
      end
    end
  end
end
