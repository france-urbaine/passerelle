# frozen_string_literal: true

require_relative "../base"
require "pathname"

module CLI
  class Setup
    class MasterKey < Base
      PATH = Pathname.new(__dir__).join("../../../config/master.key")

      def call(on_exist: "ask")
        say "Check for Rails master key"

        if exist?
          case on_exist
          when "skip"
            say ""
            say "✓ Rails master is already defined"
            say ""

            return
          when "ask"
            say ""
            say "Rails master is already defined."
            say "Would you like to update it ? [Yn]"

            return if ask != "Y"
          end
        end

        say "Setup Rails master key"
        say "The key is shared in Dashlane."
        say ""
        say "Please enter the master key:"

        master_key = ask(secret: true)
        raise "Invalid key" if master_key.empty?

        PATH.open("w") do |f|
          f.puts master_key
        end

        say ""
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
