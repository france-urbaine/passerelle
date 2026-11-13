# frozen_string_literal: true

require "irb/color"
require "English"
require "optparse"

module CLI
  class Base
    def self.run
      call(*ARGV)
    end

    def self.call(...)
      new.call(...)
    end

    private

    def say(message)
      if message.empty?
        $stdout.puts output_prefix
      else
        lines = message.split("\n")
        lines.each do |line|
          $stdout.puts "#{output_prefix} #{line}"
        end
      end
    end

    def ask(message = nil, secret: false, loop_empty: false, end_say: "")
      require "io/console" if secret

      message = ask_message(message)

      loop do
        $stdout.print message
        result = secret ? $stdin.getpass : $stdin.gets(chomp: true)

        next if result.empty? && loop_empty

        say(end_say) if end_say

        return result
      end
    end

    def ask_message(message)
      if message.nil? || message.empty?
        "#{output_prefix} > "
      else
        message.split("\n")
          .map { |line| "#{output_prefix} #{line}" }
          .join("\n")
      end
    end

    def run(*args, env: {}, abort_on_failure: true)
      args_splat = []
      args_splat << env if env
      args_splat += args

      command = env.map { |k, v| "#{k}=#{v.inspect} " }.join
      command += args.join(" ")

      say colorize(command, :YELLOW)

      result = system(*args_splat)

      if result
        result
      else
        say "#{colorize(command, :RED)} failed"
        abort if abort_on_failure
      end
    end

    def run_succeed?
      $CHILD_STATUS&.success?
    end

    def run_failed?
      $CHILD_STATUS && !$CHILD_STATUS.success?
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

    def command_available?(command)
      system("command", "-v", command, out: File::NULL)
    end

    def program_name
      $PROGRAM_NAME
    end

    def output_prefix
      @output_prefix ||= colorize("[ #{program_name} ]", :BLUE)
    end

    def colorize(message, color = nil)
      IRB::Color.colorize(message, [color].compact)
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
