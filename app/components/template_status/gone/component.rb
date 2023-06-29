# frozen_string_literal: true

module TemplateStatus
  module Gone
    class Component < TemplateStatus::Component
      def initialize(record = nil, **options)
        @record = record
        @options = options
        super()
      end

      def deletion_delay
        @record && DeleteDiscardedRecordsJob::DELETION_DELAYS[@record.class.name]
      end

      def deletion_date
        @record && deletion_delay&.after(@record.discarded_at.to_date)
      end
    end
  end
end
