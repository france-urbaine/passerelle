# frozen_string_literal: true

require "irb/color"
require "English"
require "zeitwerk"

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
loader = Zeitwerk::Loader.new
loader.inflector.inflect("ci" => "CI")
loader.push_dir(__dir__, namespace: CLI)
loader.setup
