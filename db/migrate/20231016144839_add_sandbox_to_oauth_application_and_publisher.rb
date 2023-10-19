# frozen_string_literal: true

class AddSandboxToOauthApplicationAndPublisher < ActiveRecord::Migration[7.0]
  def change
    change_table :oauth_applications do |t|
      t.boolean :sandbox, null: false, default: false
    end
    change_table :publishers do |t|
      t.boolean :sandbox, null: false, default: false
    end
  end
end
