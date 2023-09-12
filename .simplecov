# frozen_string_literal: true

SimpleCov.start "rails" do
  # When runnning `bin/ci` unit tests and system tests are ran in two separate processes.
  # To merge both coverage results, we need to setup a custom command:
  #
  command_name ENV["SIMPLE_COV_COMMAND"] if ENV.key?("SIMPLE_COV_COMMAND")

  add_group "Components", "app/components"
  add_group "Policies", "app/policies"
  add_group "Services", "app/services"
end
