# frozen_string_literal: true

require_relative "../../lib/extras/lines_commander"
require "optparse"

module CLI
  class Base
    include LinesCommander

    # `bin/dx <name>` shortcuts that CLI::Base#bin_prefix can suggest instead of the
    # fully spelled out `bin/dx exec bin/<name>` — see CLI::Docker::Default#call for the
    # shortcuts themselves. Keyed on the exact string #bin_prefix builds before checking
    # for a shortcut, i.e. "bin/dx exec bin/<name>" (or "bin/dx exec bin/<name> <extra>"
    # for a two-word shortcut like `dev server`).
    #
    KNOWN_SHORTCUTS = {
      "bin/dx exec bin/rails"      => "bin/dx rails",
      "bin/dx exec bin/setup"      => "bin/dx setup",
      "bin/dx exec bin/ci"         => "bin/dx ci",
      "bin/dx exec bin/update"     => "bin/dx update",
      "bin/dx exec bin/upgrade"    => "bin/dx upgrade",
      "bin/dx exec bin/dev server" => "bin/dx dev server",
      "bin/dx exec bin/dev jobs"   => "bin/dx dev jobs",
      "bin/dx exec bin/dev"        => "bin/dx dev"
    }.freeze

    def self.run
      call(*ARGV)
    end

    def self.call(...)
      new.call(...)
    end

    private

    # Suppress the "→ ClassName" suffix LinesCommander.program_name adds by default
    #
    def program_name
      $PROGRAM_NAME
    end

    # An helper to parse command options.
    # Example:
    #
    #   def call(*)
    #     args, options = parse_options!(*, with: options_parser)
    #     ...
    #   end
    #
    #   def call_with_options_only(*)
    #     options = parse_options!(*, with: options_parser, arguments_expected: false)
    #     ...
    #   end
    #
    #   def options_parser
    #     OptionParser.new do |parser|
    #       parser.on("-s SERVICE", "--service SERVICE")
    #       parser.on("--verbose")
    #     end
    #   end
    #
    # When the command defines a #help method, the options -h & --help
    # are available and call it.
    #
    # See https://docs.ruby-lang.org/en/4.0/OptionParser.html
    #
    def parse_options!(*args, with: OptionParser.new, arguments_expected: true, raise_unknown: true)
      options     = {}
      parser      = with
      help_method = self.class.method_defined?(:help)

      parser.raise_unknown = raise_unknown

      if help_method
        parser.on("-h", "--help") do
          help
          exit
        end
      end

      begin
        # Use #order! instead of #parse! so the parser breaks
        # when a non-switch argument is met.
        # Example:
        #    bin/dx exec -s app bin/setup project --mode empty
        #
        parser.order!(args, into: options)

        if arguments_expected
          return [args, options]
        elsif args.any?
          unexpected_args!(args)
        else
          return options
        end
      rescue OptionParser::ParseError => e
        say colorize(e.message, :RED)
        say ""
      end

      # Using abort in the rescue block will output the exception message
      # to STDERR. So we use the begin..rescue syntax to avoid that.
      help if help_method
      abort
    end

    def unexpected_args!(args)
      say colorize("unexpected argument: #{args.join(' ')}", :RED)
      say ""

      help if self.class.method_defined?(:help)
      abort
    end

    def inside_docker_container?
      !!ENV["DOCKER"]
    end

    # ENV["DX_EXEC"] is set by `bin/dx exec` (CLI::Docker::Exec) whenever it hands a
    # command off to run inside a container — except `bin/dx exec bash` (`bin/dx sh`),
    # which opens an interactive shell a human sits in, so anything typed there afterward
    # should see itself as "already inside", not "launched from the host". Unlike
    # ENV["DOCKER"] (true for ANY process inside the container — see CLI::Setup::Hooks for
    # why it answers a different question), this is empty both when already inside an
    # interactive shell and when running directly on the host with no Docker at all — both
    # cases where the bare command is already correct.
    #
    def dx_exec_prefix
      ENV["DX_EXEC"] ? "bin/dx exec " : ""
    end

    # Builds what a human should type to run `bin/<command>` from wherever this is
    # printed: bare `bin/<command>` when already correct as-is (no DX_EXEC — see
    # #dx_exec_prefix), `bin/dx <command>` when KNOWN_SHORTCUTS has a shorter form for
    # it, or the fully spelled out `bin/dx exec bin/<command>` otherwise (e.g.
    # `bin/rake`, which has no shortcut).
    #
    # `command` must be the bare name (e.g. "ci") — bin_prefix always builds the
    # "bin/<command>" form itself, so passing "bin/ci" would double it up.
    #
    def bin_prefix(command = nil)
      return "#{dx_exec_prefix}bin/#{command}" if command.nil?

      command = command.delete_prefix("bin/")
      command = "#{dx_exec_prefix}bin/#{command}"

      replace_command_by_shortcut(command)
    end

    def replace_command_by_shortcut(command)
      KNOWN_SHORTCUTS.each do |a, b|
        return command.sub(/\A#{a}/, b) if command.start_with?(a)
      end

      command
    end
  end
end

# Configure autoloading in this directory
#
# Zeitwerk is missing when gems are not installed on the host, for example
# when running everything through Docker with `bin/dx`.
# Commands which must run without gems require their dependencies explicitly.
#
begin
  require "zeitwerk"
rescue LoadError
  return
end

loader = Zeitwerk::Loader.new
loader.inflector.inflect("ci" => "CI")
loader.push_dir(__dir__, namespace: CLI)
loader.setup
