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

      def deletion_time
        discarded_record && deletion_delay&.after(discarded_record.discarded_at)&.end_of_day
      end

      def deletion_distance_from_now_in_words
        return unless deletion_time

        distance_in_seconds = (deletion_time.to_time - Time.current.to_time)
        distance_in_hours   = distance_in_seconds / 3600.0
        distance_in_days    = (distance_in_hours / 24.0).floor

        case distance_in_hours
        when 0..16  then "ce soir vers minuit"
        when 16..24 then "dans moins de 24 heures"
        when 24..   then "dans #{I18n.t(:x_days, count: distance_in_days, scope: 'datetime.distance_in_words')}"
        end
      end
    end
  end
end
