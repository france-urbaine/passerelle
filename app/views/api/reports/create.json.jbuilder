# frozen_string_literal: true

if @report.errors.any?
  json.errors @report.errors.messages
else
  json.id @report.id
end
