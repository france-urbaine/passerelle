# frozen_string_literal: true

require "irb/color"
require "English"
require "open3"

module LinesCommander
  module_function

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

  # When a block is passed to run
  # It yield stding, stdout, stdout when the waiting thread (See Open3.popen3)
  # It must return an Array with a successful boolean and the result to return
  # Example:
  #
  #   result = run(command) do |_in, out, err, thread|
  #     result = +""
  #     err.each { puts it; capture << it }
  #
  #     success = result.empty?
  #     [success, result]
  #   end
  #
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def run(*args, env: {}, secret_env: {}, abort_on_failure: true, timing: false, capture: false, &)
    command_inspect  = env.map { |k, v| "#{k}=#{v.inspect}" }
    command_inspect += secret_env.map { |k, _| "#{k}=[REDACTED]" }
    command_inspect += args
    command_inspect  = command_inspect.join(" ")

    say colorize(command_inspect, :YELLOW)

    env.merge!(secret_env)

    start_at = Time.now if timing

    if block_given?
      success, result = Open3.popen2e(env, *args, &)
    elsif capture
      result, status = Open3.capture2(env, *args)
      success = status.success?
    else
      result  = system(env, *args)
      success = result
    end

    elasped = (Time.now - start_at).round if timing

    if success
      say "#{colorize(command_inspect, :GREEN)} ran successfully after #{time_display(elasped)}" if timing
      result
    else
      if timing
        say "#{colorize(command_inspect, :RED)} failed after #{time_display(elasped)}"
      else
        say "#{colorize(command_inspect, :RED)} failed"
      end

      if abort_on_failure
        abort
      else
        result
      end
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity

  def command_available?(command)
    system("which", command, out: File::NULL, err: File::NULL)
  end

  def program_name
    name = $PROGRAM_NAME
    name = "#{name} #{Rake.application.top_level_tasks.join(' ')}" if rake_tasks?
    name = "#{name} → #{self.class}" unless equal?(LinesCommander)
    name
  end

  def rake_tasks?
    defined?(Rake.application) && Rake.application.top_level_tasks.any?
  end

  def output_prefix
    @output_prefix ||= colorize("[ #{program_name} ]", :BLUE)
  end

  def colorize(message, *colors)
    IRB::Color.colorize(message, colors.flatten.compact)
  end

  def time_display(seconds)
    case seconds
    when 0..60
      "#{seconds}s"
    when 60..3600
      if (seconds % 60).zero?
        "#{(seconds / 60).ceil}min"
      else
        "#{(seconds / 60).ceil}min and #{seconds % 60}s"
      end
    when (3600..)
      minutes = (seconds / 60).round

      if (minutes % 60).zero?
        "#{(minutes / 60).ceil}h"
      else
        "#{(minutes / 60).ceil}h and #{minutes % 60}min"
      end
    end
  end

  def confirm_before_calling_destructive_method(message = nil)
    if message.nil?
      call    = caller_locations(1, 1)[0]
      path    = Pathname.new(call.path)
      message = <<~MESSAGE
        The following method is potentially destructive:

            #{colorize(call.label, :BOLD)}
            (#{path})
      MESSAGE
    end

    say ""
    say "❗ ❗ ❗ ❗ ❗ ❗ ❗ ❗ ❗ ❗ ❗ ❗ ❗ ❗ ❗ ❗ ❗ ❗ ❗ ❗ ❗ ❗ ❗ ❗ ❗"
    say ""
    say "                            ⚠️    WARNING    ⚠️                            "
    say ""
    say message
    say ""
    say "Context:"
    say ""
    say "     RAILS_ENV is not defined (default to 'development')"  if ENV["RAILS_ENV"].nil?
    say "     RAILS_ENV is set to #{ENV['RAILS_ENV'].inspect}"      if ENV["RAILS_ENV"]
    say "     DOTENV    is set to #{ENV['DOTENV'].inspect}"         if ENV["DOTENV"]
    say ""
    say "❗ ❗ ❗ ❗ ❗ ❗ ❗ ❗ ❗ ❗ ❗ ❗ ❗ ❗ ❗ ❗ ❗ ❗ ❗ ❗ ❗ ❗ ❗ ❗ ❗"
    say ""
    say "Please confirm you want to continue [Y]"
    return if ask == "Y"

    # Inside IRB (Rails console, binding.irb), exiting would close the whole session:
    # only interrupt the current command.
    raise "execution interrupted" if irb_session?

    abort
  end

  def irb_session?
    defined?(IRB.CurrentContext) && !IRB.CurrentContext.nil?
  end
end
