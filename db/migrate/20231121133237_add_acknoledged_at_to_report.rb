# frozen_string_literal: true

class AddAcknoledgedAtToReport < ActiveRecord::Migration[7.0]
  def change
    add_column :reports, :acknowledged_at, :datetime
  end
end
