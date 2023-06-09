# frozen_string_literal: true

class RefactorSandboxPackages < ActiveRecord::Migration[7.0]
  def change
    add_column :packages, :sandbox, :boolean, null: false, default: false
    remove_column :reports, :sandbox, :boolean, null: false, default: false
  end
end
