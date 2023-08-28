# frozen_string_literal: true

module Views
  module Collectivities
    class ListComponent < ApplicationViewComponent
      DEFAULT_COLUMNS = %i[
        name
        siren
        publisher
        contact
        contact_email
        contact_phone
        users_count
        packages_transmitted_count
        reports_transmitted_count
        reports_approved_count
        reports_rejected_count
      ].freeze

      def initialize(collectivities, pagy = nil, namespace:, parent: nil)
        @collectivities = collectivities
        @pagy           = pagy
        @namespace      = namespace
        @parent         = parent
        super()
      end

      def before_render
        content
        @columns = DEFAULT_COLUMNS if columns.empty?

        @collectivities = @collectivities.preload(:publisher) if columns.include?(:publisher)
      end

      def with_column(name)
        columns << name
      end

      def columns
        @columns ||= []
      end

      def nested?
        @parent
      end

      def namespace_module
        @namespace_module ||= @namespace.to_s.classify.constantize
      end

      # Disable these layout cops to allow more comparable lines
      #
      # rubocop:disable Layout/LineLength
      # rubocop:disable Layout/ExtraSpacing
      #
      def allowed_to_show?(collectivity)
        case @namespace
        when :territories                  then allowed_to?(:show?, collectivity, with: Admin::CollectivityPolicy)
        else                                    allowed_to?(:show?, collectivity, with: namespace_module::CollectivityPolicy)
        end
      end

      def allowed_to_edit?(collectivity)
        case @namespace
        when :territories                  then false
        else                                    allowed_to?(:edit?, collectivity, with: namespace_module::CollectivityPolicy)
        end
      end

      def allowed_to_remove?(collectivity)
        case @namespace
        when :territories                  then false
        else                                    allowed_to?(:remove?, collectivity, with: namespace_module::CollectivityPolicy)
        end
      end

      def allowed_to_remove_all?
        case @namespace
        when :admin                        then [DDFIP, Office].exclude? @parent.class
        when :territories                  then false
        else                                    allowed_to?(:destroy_all?, Collectivity, with: namespace_module::CollectivityPolicy)
        end
      end

      def show_path(collectivity)
        case @namespace
        when :territories                  then polymorphic_path([:admin, collectivity])
        else                                    polymorphic_path([@namespace, collectivity])
        end
      end

      def edit_path(collectivity)
        case @namespace
        when :territories                  then polymorphic_path([:edit, :admin, collectivity])
        else                                    polymorphic_path([:edit, @namespace, collectivity])
        end
      end

      def remove_path(collectivity)
        case @namespace
        when :territories                  then polymorphic_path([:remove, :admin, collectivity])
        else                                    polymorphic_path([:remove, @namespace, collectivity])
        end
      end

      def allowed_to_show_publisher?
        case @namespace
        when :organization                 then @parent.instance_of?(Office) ? false : allowed_to?(:show?, Publisher, with: Admin::PublisherPolicy)
        when :territories                  then allowed_to?(:show?, Publisher, with: Admin::PublisherPolicy)
        else                                    allowed_to?(:show?, Publisher, with: namespace_module::PublisherPolicy)
        end
      end

      def publisher_show_path(publisher)
        case @namespace
        when :organization, :territories then polymorphic_path([:admin, publisher])
        else                                  polymorphic_path([@namespace, publisher])
        end
      end
      #
      # rubocop:enable Layout/LineLength
      # rubocop:enable Layout/ExtraSpacing
    end
  end
end
