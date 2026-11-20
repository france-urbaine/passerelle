# frozen_string_literal: true

require_relative "../base"

module CLI
  module CI
    class Brakeman < Base
      def call(*args)
        parse_options!(*args, raise_unknown: false)

        say "Analyzing code for security vulnerabilities"

        command = %w[bundle exec brakeman]

        unless args.include?("--interactive-ignore")
          command << "--ensure-latest"
          command << "--color"
          command << "--output /dev/stdout"
          command << "--output tmp/brakeman.html"
        end

        command += args

        return if run command.join(" "), abort_on_failure: false

        say ""
        say "Did you know you can run `#{bin_prefix('ci')} brakeman --interactive-ignore`"
        say "to select warnings to ignore ?"
        say ""
        abort
      end

      def help
        say <<~HEREDOC
          Usage:

              #{bin_prefix('ci')} brakeman [OPTIONS]

          A command script to run Brakeman and check for code vulnerabilities.
          It accepts all options and argument used by brakeman:
          \x5
        HEREDOC

        run "bundle exec brakeman --help"
      end
    end
  end
end
