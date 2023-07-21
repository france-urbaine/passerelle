# frozen_string_literal: true

module TemplateStatus
  module Gone
    class Component < TemplateStatus::Component
      def initialize(*records, **options)
        @records = records.flatten
        @options = options
        super()
      end

      def discarded_record
        @records.first
      end

      def deletion_delay
        discarded_record && DeleteDiscardedRecordsJob::DELETION_DELAYS[discarded_record.class.name]
      end

      def deletion_date
        discarded_record && deletion_delay&.after(discarded_record.discarded_at.to_date)
      end
    end
  end
end
