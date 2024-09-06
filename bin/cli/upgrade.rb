# frozen_string_literal: true

require_relative "base"

module CLI
  class Upgrade < Base
    def call(*args)
      case args[0]
      when "bundle" then CLI::Upgrade::Bundle.call
      when "yarn"   then CLI::Upgrade::Yarn.call
      when "icons"  then CLI::Upgrade::Icons.call
      else help
      end
    end

    def help
      say <<~HEREDOC
        Upgrade commands:

            bin/upgrade bundle   # Upgrade gems through an interactive command
            bin/upgrade yarn     # Upgrade JS packages through an interactive command
            bin/upgrade icon     # Upgrade icons sets (heroicons)"
            bin/upgrade help     # Show this help
        \x5
      HEREDOC
    end
  end
end
