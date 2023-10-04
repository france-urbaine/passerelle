# frozen_string_literal: true

if @service.errors.any?
  json.errors @service.errors.messages
else
  json.id @transmission.id
  json.completed_at @transmission.completed_at
  json.packages @transmission.packages do |package|
    json.id package.id
    json.name package.name
    json.reference package.reference
    json.reports package.reports do |report|
      json.id report.id
      json.reference report.reference
    end
  end
end
