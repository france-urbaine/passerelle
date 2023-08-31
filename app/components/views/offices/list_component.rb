# frozen_string_literal: true

module Views
  module Offices
    class ListComponent < ApplicationViewComponent
      DEFAULT_COLUMNS = %i[
        name
        ddfip
        competence
        users_count
        communes_count
        reports_count
        reports_approved_count
        reports_rejected_count
      ].freeze

      def initialize(offices, pagy = nil, namespace:, parent: nil)
        @offices   = offices
        @pagy      = pagy
        @namespace = namespace
        @parent    = parent
        super()
      end

      def before_render
        content
        @columns = DEFAULT_COLUMNS if columns.empty?

        @offices = @offices.preload(:ddfip) if columns.include?(:ddfip)
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

      def allowed_to_show?(office)
        allowed_to?(:show?, office, with: namespace_module::OfficePolicy)
      end

      def allowed_to_edit?(office)
        allowed_to?(:edit?, office, with: namespace_module::OfficePolicy)
      end

      def allowed_to_remove?(office)
        allowed_to?(:remove?, office, with: namespace_module::OfficePolicy)
      end

      def allowed_to_remove_all?
        case [@namespace, @parent]
        in [:admin, Collectivity] then false
        else                           allowed_to?(:destroy_all?, Office, with: namespace_module::OfficePolicy)
        end
      end

      def allowed_to_show_ddfip?(ddfip)
        case [@namespace, @parent]
        in [:organization, nil] then false
        else                         allowed_to?(:show?, ddfip, with: namespace_module::DDFIPPolicy)
        end
      end

      def show_path(office)
        polymorphic_path([@namespace, office])
      end

      def edit_path(office)
        polymorphic_path([:edit, @namespace, office])
      end

      def remove_path(office)
        polymorphic_path([:remove, @namespace, office])
      end

      def show_ddfip_path(ddfip)
        polymorphic_path([@namespace, ddfip])
      end
    end
  end
end
