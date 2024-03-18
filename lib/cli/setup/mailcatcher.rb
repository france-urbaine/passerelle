# frozen_string_literal: true

require_relative "../base"

module CLI
  class Setup
    class Mailcatcher < Base
      GEM_INSTALL_COMMAND = "gem install mailcatcher --pre --no-document"

      def call
        if command_available?("rvm")
          say <<~MESSAGE
            RVM is installed.
            It is recommended to install mailcatcher using the following commands:

                rvm default@mailcatcher --create do #{GEM_INSTALL_COMMAND}
                ln -s "$(rvm default@mailcatcher do gem wrapper show mailcatcher)" "$rvm_bin_path/"

            To read more:

              . https://github.com/sj26/mailcatcher?tab=readme-ov-file#rvm

            \x5
          MESSAGE
        end

        say <<~MESSAGE
          Mailcatcher could be installed using `gem install`.
          This is NOT RECOMMENDED cause it could lead to conflicts in executables.
          Do you want to install it anyway ? [Yn]
        MESSAGE

        abort unless ask == "Y"

        run GEM_INSTALL_COMMAND, abort_on_failure: false
        return if run_succeed?

        say <<~MESSAGE
          #{colorize(GEM_INSTALL_COMMAND, :RED)} failed
          Read more about potential issues:

            . https://github.com/eventmachine/eventmachine/issues/936
            . https://github.com/sj26/mailcatcher#rvm
            . https://github.com/sj26/mailcatcher#ruby
          \x5
        MESSAGE
      end
    end
  end
end
