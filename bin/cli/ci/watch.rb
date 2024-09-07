# frozen_string_literal: true

require_relative "../base"

module CLI
  class CI
    class Watch < Base
      def call(plugin = nil)
        say "Starting Guard"

        env     = build_env
        command = build_command(plugin)

        run command, env: env
      end

      def build_command(plugin)
        plugin = "factorybot" if plugin == "factories"

        command = "bundle exec guard"
        command += " -P #{plugin}" if plugin
        command
      end

      def build_env
        env = {}
        env["POSTGRESQL_DATABASE"] = ENV.fetch("POSTGRESQL_DATABASE", "passerelle_test_watch")
        env["LOG_PATH"]            = ENV.fetch("LOG_PATH", "log/watch.log")
        env["SKIP_ALL_ON_START_WARNING"] = "true"
        env
      end
    end
  end
end
