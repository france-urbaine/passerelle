# frozen_string_literal: true

Rails.application.configure do
  config.action_view.field_error_proc = ->(html_tag, _) { html_tag }
end
