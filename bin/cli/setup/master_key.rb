# frozen_string_literal: true

require_relative "../base"
require "pathname"

module CLI
  class Setup
    class MasterKey < Base
      PATH = Pathname.new(__dir__).join("../../../config/master.key")

      def call
        say "Check for Rails master key"

        if exist?
          say "" # rubocop:disable Style/IdenticalConditionalBranches
          say "Rails master is already defined."
          say "Would you like to update it ? [Yn]"

          return if ask != "Y"
        else
          say "" # rubocop:disable Style/IdenticalConditionalBranches
          say "No master key found."
        end

        say "Setting up master key."
        say "The key is shared in Dashlane."
        say ""
        say "Please enter the master key (or press Enter to ignore):"

        master_key = ask(secret: true, loop_empty: true)

        PATH.open("w") do |f|
          f.puts master_key
        end

        say "✓ Master key is saved at `config/master.key` !"
        say ""
      end

      def exist?
        return true if PATH.exist?

        require "dotenv"

        Dotenv.load(".env.local", ".env")
        ENV.key?("RAILS_MASTER_KEY")
      end
    end
  end
end
