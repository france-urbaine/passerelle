# frozen_string_literal: true

if @result.failure?
  json.errors @service.errors.messages
else
  json.extract! @transmission, :id, :completed_at
  json.packages @transmission.packages do |package|
    json.extract! package, :id, :name, :reference
    json.reports package.reports do |report|
      json.extract! report, :id, :reference
    end
  end
end
