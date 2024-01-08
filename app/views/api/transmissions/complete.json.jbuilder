# frozen_string_literal: true

if @result.failure?
  json.errors @service.errors.messages
else
  json.transmission do
    json.extract! @transmission, :id, :completed_at
    json.packages @transmission.packages do |package|
      json.extract! package, :id, :reference
      json.reports package.reports, :id, :reference
    end
  end
end
