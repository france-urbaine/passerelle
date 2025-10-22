# frozen_string_literal: true

module Views
  module Reports
    module Show
      module Timeline
        class Component < ApplicationViewComponent
          def initialize(report)
            @report = report
            super()
          end

          def step_title(viewer_type, step)
            t(".#{viewer_type}.#{step}.#{report_state}.title", default: t(".#{viewer_type}.#{step}.title"))
          end

          def step_status(viewer_type, step)
            t(".#{viewer_type}.#{step}.#{report_state}.status", default: t(".#{viewer_type}.#{step}.status"))
          end

          def step_text(viewer_type, step, options = {})
            t(".#{viewer_type}.#{step}.#{report_state}.text", default: t(".#{viewer_type}.#{step}.text"), **options)
          end

          def viewer_type
            case current_organization&.model_name&.element
            when "collectivity", "publisher" then :collectivity
            when "dgfip", "ddfip_admin"      then :ddfip_admin
            when "ddfip_user"                then :ddfip_user
            when "ddfip"                     then ddfip_viewer_type
            end
          end

          def  ddfip_viewer_type
            if current_user.organization_admin? || current_user.user_form_types.any?
              :ddfip_admin
            else
              :ddfip_user
            end
          end

          def report_state
            @report_state ||=
              if viewer_type == :collectivity
                if @report.packing? && @report.in_active_transmission?
                  :in_active_transmission
                else
                  @report.state
                end
              else
                @report.state
              end
          end

          def translate_enum(value, **)
            I18n.t(value, **, default: "") if value.present?
          end
        end
      end
    end
  end
end
