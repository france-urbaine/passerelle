# frozen_string_literal: true

require_relative "../base"
require "pathname"

module CLI
  class Setup
    class MasterKey < Base
      PATH = Pathname.new(__dir__).join("../../../config/master.key")

      def call
        say "Check for Rails master key"
        exist = exist?

        say ""

        if exist && ENV["IGNORE_EXISTING_KEY"]
          say "✓ Master key already set up !"
          say ""
          return

        elsif exist
          say "Master key is already set up."
          say "Would you like to update it ? [Yn]"

          if ask != "Y"
            say "✓ Master key already set up !"
            say ""
            return
          end

        else
          say "No master key found."
        end

        say ""
        say "To get the actual master key, please contact us at:"
        say "   cto@solutions-territoire.fr"
        say ""
        say "Please enter the master key (or press Enter to ignore):"

        master_key = ask(secret: true)
        return if master_key.empty?

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
