# frozen_string_literal: true

# This file is excluded from coverage reports.
#
# :nocov:

require "guard/compat/plugin"

module Guard
  class Run < Guard::Plugin
    def start
      Guard::Compat::UI.info "Guard::Run is running"
      run_command if options[:all_on_start]
    end

    def run_all
      run_command
    end

    def run_on_modifications(*)
      run_command
    end

    def run_command
      Guard::Compat::UI.info "Running `#{options[:cmd]}`"
      throw :task_has_failed unless system(options[:cmd])
    end
  end
end
# :nocov:
