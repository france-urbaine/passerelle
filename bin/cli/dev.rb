# frozen_string_literal: true

require_relative "base"

module CLI
  class Dev < Base
    def call(*args)
      case args[0]
      when nil            then start
      when "server"       then start_server
      when "jobs"         then start_jobs
      when "mailcatcher"  then start_mailcatcher
      when "help"         then help
      else start_process(*args)
      end
    end

    def help
      say <<~HEREDOC
        Development commands:

            bin/dev                   # Start all default processes
            bin/dev server            # Start only processes required to serve the application (web, js & css)
            bin/dev jobs              # Start backgrounder process(es)
            bin/dev mailcatcher       # Start mailcatcher in foreground mode
            bin/dev help              # Show this help

        Server processes could be start individually:

            bin/dev web               # Start only rails server
            bin/dev js                # Start only dev server to bundle JS
            bin/dev css               # Start only dev server to bundle CSS

        Background processes could be start individually:

            bin/dev sidekiq           # Start only Sidekiq
        \x5
      HEREDOC
    end

    def start(*processes, socket: nil)
      command = process_manager
      command += " start "

      options =
        case process_manager
        when "overmind" then overmind_options(processes, socket: socket)
        when "foreman"  then foreman_options(processes)
        end

      command += options.map { |(k, v)| "-#{k} #{v}".strip }.join(" ")

      run command
    end

    def start_server
      start(:web, :js, :css)
    end

    def start_jobs
      start(:sidekiq, socket: "background")
    end

    def start_mailcatcher
      unless command_available?("mailcatcher")
        say "Mailcatcher is not installed or the command is not available"
        abort
      end

      start(:mailcatcher, socket: "mailcatcher")
    end

    def start_process(name)
      if name == "web"
        start(:web)
      else
        start(name, socket: name)
      end
    end

    private

    def process_manager
      @process_manager ||=
        if command_available?("overmind")
          "overmind"
        elsif command_available?("foreman")
          "foreman"
        else
          say "Installing foreman..."
          run "gem install foreman"
          "foreman"
        end
    end

    # Overmind & Foreman assigns the port base (5000 by default) to `PORT` for the
    # first process and increases `PORT` by port step (100 by default) for each
    # subsequent one.
    #
    # See:
    #   https://github.com/ddollar/foreman/blob/master/lib/foreman/engine.rb#L264
    #   https://github.com/DarthSim/overmind/blob/master/README.md#specifying-the-ports
    #
    # However:
    #   * the port 3000 is well known to be the default port for Rails server
    #   * the port 5000 is already used by the OS since MacOS 12.0.1
    #     See: https://github.com/DarthSim/overmind/issues/119
    #
    # Overmind suggests to set another OVERMIND_PORT but if we override it by default
    # here, we cannot then override it on needed.
    # So we disabled this behavior with -N option.
    #
    # Finally, you can override the port used by Rails with the command `PORT=<port> bin/dev`
    # or by setting `PORT=<port>` in an `.overmind.env` file.
    #
    def overmind_options(processes, socket:)
      options = {}
      options[:f] = "Procfile.dev"

      if (processes.empty? || processes.include?(:mailcatcher)) && command_available?("mailcatcher")
        options[:f] = "Procfile.dev+mailcatcher"
      end

      options[:N] = ""
      options[:l] = processes.join(",") if processes.any?
      options[:s] = "./.overmind_#{socket}.sock" if socket
      options
    end

    def foreman_options(processes, **)
      if processes.empty? && command_available?("mailcatcher")
        say "Mailcatcher is installed but cannot be run with foreman."
        say "You should consider installing overmind."
      elsif processes.include?(:mailcatcher)
        say "Mailcatcher cannot be run with foreman."
        say "You should consider installing overmind."
        abort
      end

      options = {}
      options[:f] = "Procfile.dev"
      options[:p] = ENV.fetch("PORT", 3000) if processes.empty? || processes.include?(:web)
      options[:m] = processes.map { |s| "#{s}=1" }.join(",") if processes.any?
      options
    end
  end
end
