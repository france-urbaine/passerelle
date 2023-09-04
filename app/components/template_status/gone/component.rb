# frozen_string_literal: true

module TemplateStatus
  module Gone
    class Component < ApplicationViewComponent
      renders_one :header, "LabelOrContent"
      renders_one :body, "LabelOrContent"
      renders_many :actions, ::Button::Component
      renders_one :breadcrumbs, ->(**options) { ::Breadcrumbs::Component.new(heading: false, **options) }

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

      # NOTE: Brakeman cannot parse pattern matching in slim templates
      # That why we use a method instead
      #
      # We definitely can't make simpler than this case statement
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      #
      def gone_resource_message
        case @records
        in [Publisher, User] | [Collectivity, User] | [DDFIP, User]
          "L'organisation de cet utilisateur est en cours de suppression."
        in [Publisher, Collectivity]
          "L'éditeur de cette collectivité est en cours de suppression."
        in [Publisher]
          "Cet éditeur est en cours de suppression."
        in [DDFIP, Office]
          "La DDFIP de ce guichet est en cours de suppression."
        in [DDFIP]
          "Cette DDFIP est en cours de suppression."
        in [DGFIP]
          "Cette DGFIP est en cours de suppression."
        in [Collectivity]
          "Cette collectivité est en cours de suppression."
        in [Office]
          "Ce guichet est en cours de suppression."
        in [User]
          "Cet utilisateur est en cours de suppression."
        in [Package, Report]
          "Le paquet de ce signalement est en cours de suppression."
        in [Report]
          "Ce signalement est en cours de suppression."
        in [Package]
          "Ce paquet est en cours de suppression."
        in [OauthApplication]
          "Cette application est en cours de suppression."
        else
          "Cette ressource est en cours de suppression."
        end
      end
      #
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/PerceivedComplexity
    end
  end
end
