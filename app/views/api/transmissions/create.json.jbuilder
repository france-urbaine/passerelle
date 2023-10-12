# frozen_string_literal: true

if @transmission.errors.any?
  json.errors @transmission.errors.messages
else
  json.transmission @transmission, :id
end
