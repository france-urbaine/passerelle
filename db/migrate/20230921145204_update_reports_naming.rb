# frozen_string_literal: true

class UpdateReportsNaming < ActiveRecord::Migration[7.0]
  def change
    change_table :reports do |t|
      t.rename :situation_occupation,                   :situation_nature_occupation
      t.rename :situation_annee_fichier_cfe,            :situation_annee_cfe
      t.rename :situation_vacances_fiscales,            :situation_vacance_fiscale
      t.rename :situation_nombre_annee_vacances,        :situation_nombre_annees_vacance
      t.rename :proposition_occupation_annee_concernee, :proposition_occupation_annee
      t.rename :proposition_occupation,                 :proposition_nature_occupation
    end
  end
end
