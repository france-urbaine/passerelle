# frozen_string_literal: true

class UpdateReportOccupationAnnee < ActiveRecord::Migration[7.0]
  def change
    change_table :reports do |t|
      t.rename :proposition_occupation_annee, :situation_occupation_annee
    end
  end
end
