# frozen_string_literal: true

require_relative "base"

module CLI
  class Dev < Base
    def call(*args)
      case args[0]
      when nil            then start(:web, :js, :css, :sidekiq, mailcatcher: true)
      when "server"       then start(:web, :js, :css, mailcatcher: true)
      when "server:ssl"   then start(:web, :js, :css, mailcatcher: true, ssl: true)
      when "web"          then start(:web)
      when "web:ssl"      then start(:web, ssl: true)
      when "jobs"         then start(:sidekiq,  socket: "background")
      when "assets"       then start(:js, :css, socket: "assets")
      when "help"         then help
      else
        start(args[0], socket: args[0])
      end
    end

    def help
      say <<~HEREDOC
        Development command
            bin/dev                   # Start all default processes
            bin/dev help              # Show this help

        Processes can be start individually:

            bin/dev server            # Start only processes to serve the web application (Rails, JS & CSS)
            bin/dev web               # Start only rails server
            bin/dev js                # Start only esbuild to watch & bundle JS
            bin/dev css               # Start only postcss to watch & bundle CSS
            bin/dev assets            # Start processes to serve assets (JS & CSS)
            bin/dev jobs              # Start processes to perform asynchronous jobs
            bin/dev mailcatcher       # Start mailcatcher in foreground mode

        Some processes can be started with SSL:

            bin/dev server:ssl        # Same as `bin/dev server` but with SSL
            bin/dev web:ssl           # Same as `bin/dev web`    but with SSL
        \x5
      HEREDOC
    end

    private

    def start(*processes, socket: nil, ssl: false, mailcatcher: false)
      command = process_manager
      command += " start "
      command +=
        case process_manager
        when "overmind" then overmind_options(processes, ssl:, mailcatcher:, socket:)
        when "foreman"  then foreman_options(processes, ssl:)
        end

      run command
    end

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

    # Overmind & Foreman assigns a base port (5000 by default) to `PORT` for the
    # first process and increases `PORT` by port step (100 by default) for each
    # subsequent one.
    #
    # See:
    #   https://github.com/ddollar/foreman/blob/master/lib/foreman/engine.rb#L264
    #   https://github.com/DarthSim/overmind/blob/master/README.md#specifying-the-ports
    #
    # This port is used as the "public" port used to connect to the process which is
    # different than the "internal" port used by Puma and other services.
    # That's why the port 3000 might be harcoded in Procfile.
    #
    # However:
    #   * the port 3000 is well known to be the default port for Rails server
    #   * the port 5000 might already been used by the OS since MacOS 12.0.1
    #     See: https://github.com/DarthSim/overmind/issues/119
    #
    # On overmind:
    #   Overmind docs suggests to set a custom OVERMIND_PORT but if we override it
    #   here, we cannot then override it on needed
    #   (for example if you need 2 Rails server on different ports)
    #
    #   So we disabled this behavior with --no-port option.
    #
    # On foreman:
    #   The only way is to override the PORT variable.
    #
    # Finally, you can override the port used by Rails with the command `PORT=<port> bin/dev`
    # or by setting `PORT=<port>` in an `.overmind.env` file.
    #
    def overmind_options(processes, ssl:, mailcatcher:, socket:)
      processes << :mailcatcher if mailcatcher && command_available?("mailcatcher") && ENV["DOTENV"].nil?

      processes = add_ssl_processes(processes) if ssl
      processes = processes.join(",")

      options = []
      options << "--procfile=Procfile.dev"
      options << "--no-port"
      options << "--processes=#{processes}"
      options << "--socket=./.overmind_#{socket}.sock" if socket
      options.join(" ")
    end

    def foreman_options(processes, ssl:, **)
      if processes.empty? && command_available?("mailcatcher")
        say "Mailcatcher is installed but cannot be run with foreman."
        say "You should consider installing overmind."
      elsif processes.include?(:mailcatcher)
        say "Mailcatcher cannot be run with foreman."
        say "You should consider installing overmind."
        abort
      end

      port      = ENV.fetch("PORT", 3000) if processes.include?(:web)
      processes = add_ssl_processes(processes) if ssl
      formation = processes.map { |s| "#{s}=1" }.join(",")

      options = []
      options << "--procfile=Procfile.dev"
      options << "--port=#{port}" if port
      options << "--formation=#{formation}"
      options.join(" ")
    end

    def add_ssl_processes(processes)
      processes.map! do |value|
        if value == :web
          :web_ssl
        else
          value
        end
      end
    end
  end
end
