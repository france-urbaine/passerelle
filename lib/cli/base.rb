# frozen_string_literal: true

require "irb/color"
require "English"

module CLI
  class Base
    attr_reader :program_name

    def initialize(program_name)
      @program_name = program_name
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

    def ask(secret: false)
      $stdout.print "#{output_prefix} > "

      if secret
        require "io/console"
        result = $stdin.getpass
      else
        result = $stdin.gets(chomp: true)
      end

      say ""
      result
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
      elsif abort_on_failure
        say "#{colorize(command, :RED)} failed"
        abort
      end
    end

    def run_succeed?
      $CHILD_STATUS&.success?
    end

    def run_failed?
      $CHILD_STATUS && !$CHILD_STATUS.success?
    end

    def command_available?(command)
      system("command -v #{command} &> /dev/null")
    end

    def output_prefix
      @output_prefix ||= colorize("[ #{program_name} ]", :BLUE)
    end

    def colorize(message, color = nil)
      IRB::Color.colorize(message, [color].compact)
    end
  end
end
