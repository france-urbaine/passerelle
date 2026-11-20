# frozen_string_literal: true

require_relative "base"
require_relative "ci/audit"
require_relative "ci/brakeman"
require_relative "ci/factories"
require_relative "ci/rubocop"
require_relative "ci/test"
require_relative "ci/watch"
require_relative "ci/zeitwerk_check"

module CLI
  module CI
    def self.run = Default.run

    class Default < Base
      def call(command = nil, *)
        case command
        when "watch"      then CLI::CI::Watch.call(*)
        when "zeitwerk"   then CLI::CI::ZeitwerkCheck.call(*)
        when "factories"  then CLI::CI::Factories.call(*)
        when "test"       then CLI::CI::Test.call(*)
        when "rubocop"    then CLI::CI::Rubocop.call(*)
        when "brakeman"   then CLI::CI::Brakeman.call(*)
        when "audit"      then CLI::CI::Audit.call(*)
        else
          options = parse_options!(command, *, with: options_parser, arguments_expected: false)
          run_all(options)
        end
      end

      def help
        say <<~HEREDOC
          Usage:

              #{bin_prefix('ci')} [OPTIONS]
              #{bin_prefix('ci')} COMMAND

          A command script to launch one or all steps of the CI.
          Without COMMAND, it will launch every steps:

              * Check project structure and class loading through Zeitwerk
              * Check validity of test factories
              * Run the whole test suite
              * Analyze code quality with Rubocop
              * Scan code for security vulnerabilities with Brakeman
              * Audit the bundle of gems for insecure dependencies and CVE

          By default, the command stops after one step, offering the choice to retry,
          exit or ignore failures. You can also run all the processes to get a summary
          of failed ones at the end by using the option --ignore-failures.

          To run the command in CI environnement (ex: on Github), use the CI variable:

              CI=true #{bin_prefix('ci')}

          Options available when running without COMMAND:

              -e, --exit-on-failure       Stop and exit when one process failed
              -i, --ignore-failures       Ignore all failures, sum up them at the end

          Available commands are:

              #{bin_prefix('ci')} watch                Watch & run CI programs whenever file are modified
              #{bin_prefix('ci')} zeitwerk             Check project structure and class loading
              #{bin_prefix('ci')} factories            Lint test factories
              #{bin_prefix('ci')} test                 Run the test suite
              #{bin_prefix('ci')} rubocop              Analyze code quality with Rubocop
              #{bin_prefix('ci')} brakeman             Scan code for security vulnerabilities
              #{bin_prefix('ci')} audit                Audit the bundle of gems for insecure dependencies and CVE

          Run '#{bin_prefix('ci')} COMMAND --help' for more information on a command.
          \x5
        HEREDOC
      end

      def options_parser
        OptionParser.new do |parser|
          parser.on("-e", "--exit-on-failure")
          parser.on("-i", "--ignore-failures")
        end
      end

      STEPS = [
        "bin/ci factories",
        "bin/ci test unit",
        "bin/ci test --keep-coverage system",
        "bin/ci rubocop",
        "bin/ci audit",
        "bin/ci brakeman"
      ].freeze

      def run_all(options)
        run "bin/ci zeitwerk"
        say_separator

        @options      = options.dup
        @failed_steps = []

        STEPS.each { run_step(it) }

        say_results
      end

      def run_step(command)
        run(command, timing: true)
        say_separator
      rescue SystemExit
        case handle_failed_step(command)
        when :retry    then retry
        when :continue then say_separator
        when :exit
          say_separator
          say_results
          raise
        end
      end

      def say_separator
        @steps_done ||= 0
        @steps_done += 1

        total = STEPS.size + 1 # Zeitwerk check runs before the steps
        width = 64
        left  = 1 + ((width - 2) * (@steps_done - 1) / (total - 1))

        progress = "#{@steps_done} / #{total}"
        done     = "━" * left
        remain   = "━" * (width - left)

        say ""
        say colorize("#{progress} #{done}  ✦ ✦ ✦  #{remain}", :MAGENTA)
        say ""
      end

      def handle_failed_step(step)
        return :exit if @options[:"exit-on-failure"]

        if @options[:"ignore-failures"]
          @failed_steps << step
          return :continue
        end

        # No one to answer the prompt in a CI environment
        if ENV["CI"] == "true"
          @failed_steps << step
          return :exit
        end

        say ""
        say "What would you like to do ?"
        say "[r]       - retry this step"
        say "[c]       - continue to next step"
        say "[i]       - ignore all failures"
        say "[any key] - exit the process"

        case ask
        when "r"
          :retry
        when "c"
          @failed_steps << step
          :continue
        when "i"
          @failed_steps << step
          @options[:"ignore-failures"] = true
          :continue
        else
          @failed_steps << step
          :exit
        end
      end

      def say_results
        if @failed_steps.any?
          say colorize("✗ CI failed to complete the following steps:", :RED)
          say ""
          @failed_steps.each { say(colorize("    #{bin_prefix(it)}", :RED)) }
        else
          message = [
            "✓ Noice !",                                # Jake Peralta, "Brooklyn Nine-Nine"
            "✓ Super green !",                          # Ruby Rhod, "The Fifth Element"
            "✓ Yippee-Ki-Yay, motherfucker !",          # John McClane, "Die Hard"
            "✓ This is the way.",                       # Din Djarin, "The Mandalorian"
            "✓ Achievement unlocked !",
            "✓ Nailed it !",
            "✓ Shipped it !",
            "✓ It's over 9000 !",                       # Vegeta, "Dragon Ball Z"
            "✓ No bugs, only features !",
            "✓ I love it when a plan comes together.",  # Hannibal Smith, "The A-Team"
            "✓ Legen... wait for it... dary !",         # Barney Stinson, "How I Met Your Mother"
            "✓ Bazinga !",                              # Sheldon Cooper, "The Big Bang Theory"
            "✓ Woo-hoo !",                              # Homer Simpson, "The Simpsons"
            "✓ Cowabunga !"                             # "Teenage Mutant Ninja Turtles"
          ].sample

          say colorize(message, :GREEN)
        end

        say ""
      end
    end
  end
end
