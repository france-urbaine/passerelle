# frozen_string_literal: true

class AddDGFIPToOrganizationTypeEnum < ActiveRecord::Migration[7.0]
  # NOTE: ALTER TYPE ... ADD VALUE cannot be executed inside of a transaction block
  # so here we are using disable_ddl_transaction!
  # See Rails doc
  disable_ddl_transaction!

  def up
    execute "ALTER TYPE organization_type ADD VALUE IF NOT EXISTS 'DGFIP' AFTER 'DDFIP'"
  end
end
