# frozen_string_literal: true

require_relative "../base"
require "pathname"

module CLI
  module Setup
    class Credentials < Base
      ROOT_PATH = Pathname.new(__dir__).join("../../..")
      KEY_PATH  = ROOT_PATH.join("config/master.key")

      def call(*)
        options = parse_options!(*, with: options_parser, arguments_expected: false)

        say "Check for Rails master key"
        exist = exist?

        say ""

        if exist && options[:"ignore-existing"]
          say "✓ Master key is already set up !"
          say ""
          return
        end

        override = options.fetch(:"override-existing") { override_existing_key? } if exist

        if exist && !override
          say "✓ Master key is already set up !"
          say ""
          return
        end

        unless exist
          say "No master key found."
          say ""
          say "To get the actual master key, please contact us at:"
          say "   cto@solutions-territoire.fr"
          say ""
        end

        say "Please enter the master key (or press Enter to ignore):"
        master_key = ask(secret: true)
        return if master_key.empty?

        KEY_PATH.open("w") do |file|
          file.puts master_key
        end

        say "✓ Master key saved at config/master.key !"
        say ""
      end

      def help
        say <<~HEREDOC
          Usage:

              #{bin_prefix('setup')} credentials [OPTIONS]

          Check for Rails master key presence to unlock access to credentials.
          Prompt user otherwise.

          Options:

              --ignore-existing         Skip this program if a master key is found
              --override-existing       Delete and replace any existing master key
          \x5
        HEREDOC
      end

      def options_parser
        OptionParser.new do |parser|
          parser.on("--ignore-existing")
          parser.on("--override-existing")
        end
      end

      def exist?
        return true if KEY_PATH.exist?

        require "dotenv"

        Dotenv.load(".env.local", ".env")
        ENV.key?("RAILS_MASTER_KEY")
      end

      def override_existing_key?
        say "Master key is already set up."
        say "Would you like to replace it ? [Yn]"

        ask == "Y"
      end
    end
  end
end
