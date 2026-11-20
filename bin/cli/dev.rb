# frozen_string_literal: true

require_relative "base"

module CLI
  class Dev < Base
    def call(*)
      processes, options = parse_options!(*, with: options_parser, arguments_expected: true)

      validate_debug!(processes) if options[:debug]

      start(processes, options)
    end

    def help
      say <<~HEREDOC
        Usage:

            #{bin_prefix('dev')} [OPTIONS] [PROCESS, ...]

        A command script to start the servers, compilers & backgrounders.
        It uses Overmind or Foreman to start processes listed in Procfile.dev.

        To learn more about Overmind: https://github.com/DarthSim/overmind
        To learn more about Foreman:  https://github.com/ddollar/foreman

        The development environment built with Docker provides Foreman by default.
        Without arguments, it starts all processes from Procfile.dev.

        Available processes:

            web                     Start the Rails server
            js                      Start esbuild to watch & bundle JS
            css                     Start postCSS to watch & bundle CSS
            sidekiq                 Start sidekiq (see config/sidekiq.yml)
            mailcatcher             Start mailcatcher in foreground mode

        You can also use the shorcuts:

            server                  Start all the processes to serve the web application (Rails, JS & CSS)
            assets                  Start all the processes to watch & compile assets
            jobs                    Start all background processes

        Available options:

            --ssl                   Start the Rails server with SSL (See web_ssl in Procfile.dev)
            --socket <value>        Path to overmind socket (Overmind only)
            --debug                 Open a Ruby debugger port (RUBY_DEBUG_OPEN=true).
                                     Only allowed when starting a single process.
        \x5
      HEREDOC
    end

    def options_parser
      OptionParser.new do |parser|
        parser.on("--ssl")
        parser.on("--socket SOCKET")
        parser.on("--debug")
      end
    end

    private

    def validate_debug!(processes)
      return if replace_processes(processes).size == 1

      say colorize("--debug requires a single process", :RED)
      say ""
      help
      abort
    end

    def start(processes, options = {})
      options = options.dup
      env     = build_env(options.delete(:debug))

      command = process_manager
      command += " start "
      command += command_options(processes, options)

      run command, env:
    end

    def build_env(debug)
      return {} unless debug

      { "RUBY_DEBUG_OPEN" => "true" }
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

    def command_options(processes, options)
      case process_manager
      when "overmind" then overmind_options(processes, **options)
      when "foreman"  then foreman_options(processes, **options)
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
    def overmind_options(processes, ssl: false, socket: nil)
      socket ||= socket_name(processes)

      processes = replace_processes(processes, ssl:)
      processes = processes.join(",")

      options = []
      options << "--procfile=Procfile.dev"
      options << "--no-port"
      options << "--processes=#{processes}"
      options << "--socket=#{socket}" if socket
      options.join(" ")
    end

    def foreman_options(processes, ssl: false)
      processes = replace_processes(processes, ssl:)
      formation = processes.map { |s| "#{s}=1" }.join(",")

      port = ENV.fetch("PORT", 3000) if processes.intersect?(%w[web web_ssl])

      options = []
      options << "--procfile=Procfile.dev"
      options << "--port=#{port}" if port
      options << "--formation=#{formation}"
      options.join(" ")
    end

    def socket_name(processes)
      return if processes.empty?
      return if processes.size > 1

      ".overmind_#{processes.first}.sock"
    end

    def replace_processes(processes, ssl: false)
      if processes.empty?
        processes += %w[web js css sidekiq]
        processes << "mailcatcher" if mailcatcher_available?
      end

      if processes.delete("server")
        processes += %w[web js css]
        processes << "mailcatcher" if mailcatcher_available?
      end

      processes += %w[js css]  if processes.delete("assets")
      processes += %w[sidekiq] if processes.delete("jobs")
      processes  = processes.map { it == "web" ? "web_ssl" : it } if ssl
      processes.uniq
    end

    def mailcatcher_available?
      command_available?("mailcatcher") && ENV["DOTENV"].nil?
    end
  end
end
