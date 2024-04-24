# frozen_string_literal: true

SimpleCov.start "rails" do
  # When runnning `bin/ci` unit tests and system tests are ran in two separate processes.
  # To merge both coverage results, we need to setup a custom command:
  #
  if ENV.key?("SIMPLE_COV_COMMAND")
    command_name ENV["SIMPLE_COV_COMMAND"]
    command_name ENV.values_at("SIMPLE_COV_COMMAND", "TEST_ENV_NUMBER").join("-") if ENV["TEST_ENV_NUMBER"]
  end

  add_group "Components", "app/components"
  add_group "Policies", "app/policies"
  add_group "Services", "app/services"

  add_filter %r{^/lib/cli}
end
