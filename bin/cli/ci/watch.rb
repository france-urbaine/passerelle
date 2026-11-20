# frozen_string_literal: true

require_relative "../base"

module CLI
  module CI
    class Watch < Base
      DEFAULT_DATABASE = "passerelle_test_watch"
      DEFAULT_LOG_PATH = "log/watch.log"

      def call(*)
        options = parse_options!(*, with: options_parser, arguments_expected: false)

        if options[:list]
          run "bundle exec guard list"
          exit
        end

        say "Starting Guard"

        env     = build_env
        command = build_command(options[:plugin])

        run command, env: env
      end

      def help
        say <<~HEREDOC
          Usage:

              #{bin_prefix('ci')} watch [OPTIONS]

          A command script to watch file changes and perform appropriate tests
          and linter.

          Options:

              -p, --plugin       Run only the selected plugin
              -l, --list         List available plugins
          \x5
        HEREDOC
      end

      def options_parser
        OptionParser.new do |parser|
          parser.on("-p PLUGIN", "--plugin PLUGIN")
          parser.on("-l", "--list")
        end
      end

      def build_command(plugin)
        plugin = "factorybot" if plugin == "factories"

        command = "bundle exec guard"
        command += " --plugin #{plugin}" if plugin
        command
      end

      def build_env
        env = {}
        env["POSTGRESQL_DATABASE"] = ENV.fetch("POSTGRESQL_DATABASE", DEFAULT_DATABASE)
        env["LOG_PATH"]            = ENV.fetch("LOG_PATH", DEFAULT_LOG_PATH)
        env["SKIP_ALL_ON_START_WARNING"] = "true"
        env
      end
    end
  end
end
