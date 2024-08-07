# frozen_string_literal: true

class SetAnomaliesDefault < ActiveRecord::Migration[7.1]
  def change
    change_column_default :reports, :anomalies, from: nil, to: []
  end
end
