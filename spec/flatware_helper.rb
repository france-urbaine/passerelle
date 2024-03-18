# frozen_string_literal: true

# uncomment if you get a segmentation fault from the "pg" gem
# @see https://github.com/ged/ruby-pg/issues/311#issuecomment-1609970533
# ENV["PGGSSENCMODE"] = "disable"

Flatware.configure do |conf|
  conf.before_fork do
    require "rails_helper"

    ActiveRecord::Base.connection.disconnect!
  end

  conf.after_fork do |test_env_number|
    # uncomment if you're using SimpleCov and have started it in `rails_helper` as suggested here:
    # @see https://github.com/simplecov-ruby/simplecov/tree/main?tab=readme-ov-file#use-it-with-any-framework
    SimpleCov.at_fork.call(test_env_number)

    config = ActiveRecord::Base.connection_db_config.configuration_hash

    ActiveRecord::Base.establish_connection(
      config.merge(
        database: config.fetch(:database) + test_env_number.to_s
      )
    )
  end
end
