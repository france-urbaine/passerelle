# frozen_string_literal: true

class AddSingletonConstraintOnDGFIPs < ActiveRecord::Migration[7.0]
  def up
    add_index :dgfips, "(1)", unique: true, name: "singleton_dgfip_constraint"
  end
end
