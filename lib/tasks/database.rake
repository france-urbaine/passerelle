# frozen_string_literal: true

namespace :db do
  # Automatically run `db:rollback_branches` when calling `bin/update`
  #
  # By default, ActualDbSchema hook on `db:schema:dump` to run `db:rollback_branches`.
  # This behavior is missing when calling `bin/update` because we skip schema dumping
  # for performance reasons.
  #
  # The command `db:rollback_branches` could have been called directly from `bin/update`
  # but it causes the environnement to be loaded twice.
  # Add this command as a hook provides quicker command overall.
  #
  task "migrate" => :rollback_branches if ENV["QUICK_MIGRATION_UPDATE"] == "true"
end
