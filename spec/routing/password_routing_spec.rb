# frozen_string_literal: true

require "rails_helper"

RSpec.describe PasswordsController do
  it { expect(get: "/password/strength_test").to route_to("passwords#strength_test") }
end
