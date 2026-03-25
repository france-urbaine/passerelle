# frozen_string_literal: true

require_relative "../base"

module CLI
  class CI
    class Brakeman < Base
      def call(*args)
        say "Analyzing code for security vulnerabilities"

        command = %w[bundle exec brakeman]

        command << "--ensure-latest"
        command << "--color"
        command << "--output /dev/stdout"
        command << "--output tmp/brakeman.html"

        command += args

        return if run command.join(" "), abort_on_failure: false

        say ""
        say "Did you known you can run `bin/ci brakeman --interactive-ignore` to select warnings to ignore ?"
        say ""
        abort
      end
    end
  end
end
