# frozen_string_literal: true

module Views
  module Reports
    module StatusBadge
      class Component < ApplicationViewComponent
        define_component_helper :report_badge

        COLORS = {
          draft:                  "badge--yellow",
          ready:                  "badge--lime",
          sent:                   "badge--blue",
          acknowledged:           "badge--blue",
          processing:             "badge--blue",
          denied:                 "badge--red",
          approved:               "badge--green",
          rejected:               "badge--red",
          in_active_transmission: "badge--violet",
          transmitted:            "badge--blue",
          unassigned:             "badge--yellow"
        }.freeze

        def initialize(arg)
          raise TypeError, "invalid argument: #{arg.inspect}" unless arg.is_a?(Report) || arg.is_a?(Symbol)

          @argument = arg
          super()
        end

        def call
          badge_component(label, class: css_class)
        end

        def label
          t(".#{status}")
        end

        def css_class
          COLORS[status]
        end

        def status
          case @argument
          when Symbol then @argument
          when Report then report_state(@argument)
          end
        end

        private

        def report_state(report)
          case current_organization
          when DDFIP
            if report.unassigned?
              :unassigned
            else
              report.state.to_sym
            end
          when Collectivity, Publisher
            # TODO: handle resolved state confirmed by DDFIP admins
            if report.denied?
              :denied
            elsif report.transmitted?
              :transmitted
            elsif report.in_active_transmission?
              :in_active_transmission
            else
              report.state.to_sym
            end
          end
        end
      end
    end
  end
end
