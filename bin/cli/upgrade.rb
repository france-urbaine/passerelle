# frozen_string_literal: true

require_relative "base"
require_relative "upgrade/bundle"
require_relative "upgrade/icons"
require_relative "upgrade/rubocop"
require_relative "upgrade/yarn"

module CLI
  module Upgrade
    def self.run = Default.run

    class Default < Base
      def call(command = nil, *)
        case command
        when "bundle"   then CLI::Upgrade::Bundle.call(*)
        when "rubocop"  then CLI::Upgrade::Rubocop.call(*)
        when "yarn"     then CLI::Upgrade::Yarn.call(*)
        when "icons"    then CLI::Upgrade::Icons.call(*)
        else
          parse_options!(command, *, arguments_expected: false)
          help
        end
      end

      def help
        say <<~HEREDOC
          Usage:

              #{bin_prefix('upgrade')} COMMAND

          A command script to upgrade dependencies.
          Available commands are:

              #{bin_prefix('upgrade')} bundle          Upgrade gems through an interactive command
              #{bin_prefix('upgrade')} rubocop         Upgrade rubocop gems and the todo file
              #{bin_prefix('upgrade')} yarn            Upgrade JS packages through an interactive command
              #{bin_prefix('upgrade')} icons           Upgrade icons sets

          Run '#{bin_prefix('upgrade')} COMMAND --help' for more information on a command.
          \x5
        HEREDOC
      end
    end
  end
end
