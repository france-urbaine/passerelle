# frozen_string_literal: true

module Views
  module Reports
    module StatusBadge
      class Component < ApplicationViewComponent
        define_component_helper :report_status_badge

        COLORS = {
          collectivity: {
            draft:                  "badge--yellow",
            ready:                  "badge--lime",
            in_active_transmission: "badge--violet",
            transmitted:            "badge--blue",
            acknowledged:           "badge--blue",
            accepted:               "badge--sky",
            assigned:               "badge--sky",
            applicable:             "badge--sky",
            inapplicable:           "badge--sky",
            approved:               "badge--green",
            canceled:               "badge--red",
            rejected:               "badge--red"
          },
          ddfip_admin: {
            transmitted:            "badge--yellow",
            acknowledged:           "badge--yellow",
            accepted:               "badge--yellow",
            assigned:               "badge--blue",
            applicable:             "badge--lime",
            inapplicable:           "badge--orange",
            approved:               "badge--green",
            canceled:               "badge--red",
            rejected:               "badge--red"
          },
          ddfip_user: {
            assigned:               "badge--yellow",
            applicable:             "badge--lime",
            inapplicable:           "badge--orange",
            approved:               "badge--green",
            canceled:               "badge--red"
          }
        }.freeze

        def initialize(arg, as: nil)
          raise TypeError, "invalid argument: #{arg.inspect}" unless arg.is_a?(Report) || arg.is_a?(Symbol)

          @argument = arg
          @organization_type = as
          super()
        end

        def call
          badge_component(label, class: css_class)
        end

        def label
          t(".#{organization_type}.#{state}", default: "")
        end

        def css_class
          COLORS.dig(organization_type, state)
        end

        private

        def organization_type
          ::Users::RoleService.new(current_user, organization: @organization_type).viewer_type
        end

        def state
          case @argument
          when Symbol then @argument
          when Report then report_state(@argument).to_sym
          end
        end

        def report_state(report)
          if organization_type == :collectivity
            if report.packing? && report.in_active_transmission?
              :in_active_transmission
            else
              report.state
            end
          else
            report.state
          end
        end
      end
    end
  end
end
