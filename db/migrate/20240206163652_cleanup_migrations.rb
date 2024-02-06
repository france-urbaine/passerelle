# frozen_string_literal: true

class CleanupMigrations < ActiveRecord::Migration[7.1]
  def up
    return if migration_context.current_version == 2024_01_30_15_4031 # rubocop:disable Style/NumericLiterals

    say <<~MESSAGE

      =======================================================================

      Your database version is too old and past migrations have been removed.

      You'd better have to setup the database again by running `bin/setup`.

      =======================================================================

    MESSAGE

    raise ActiveRecord::MigrationError
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
