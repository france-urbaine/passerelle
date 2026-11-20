# frozen_string_literal: true

require_relative "../../lib/extras/lines_commander"
require "optparse"

module CLI
  class Base
    include LinesCommander

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
    # The options -h & --help are always available and call the #help method.
    #
    # See https://docs.ruby-lang.org/en/4.0/OptionParser.html
    #
    def parse_options!(*args, with: OptionParser.new, arguments_expected: true)
      options = {}
      parser  = with

      parser.on("-h", "--help") do
        help
        exit
      end

      begin
        # Use #order! instead of #parse! so the parser breaks
        # when a non-switch argument is met.
        # Example:
        #    bin/dx exec -s app bin/setup help
        #
        parser.order!(args, into: options)

        return [args, options] if arguments_expected
        return options if args.empty?

        say colorize("unexpected argument: #{args.join(' ')}", :RED)
      rescue OptionParser::ParseError => e
        say colorize(e.message, :RED)
      end

      # Using abort in the rescue block will output the exception message
      # to STDERR. So we use the begin..rescue syntax to avoid that.
      say ""
      help
      abort
    end

    def run_succeed?
      $CHILD_STATUS&.success?
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
