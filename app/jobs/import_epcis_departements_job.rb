# frozen_string_literal: true

# This job use files provided by INSEE :
#   https://www.insee.fr/fr/information/2510634
#
# You can launch the job using :
#   ImportEpcisDepartementsJob.perform_now("https://www.insee.fr/fr/statistiques/fichier/2510634/Intercommunalite_Metropole_au_01-01-2022.zip")
#
# This job is called when seeding Data :
#   rails db:seed
#
class ImportEpcisDepartementsJob < ApplicationJob
  queue_as :default

  def perform(url)
    path  = Downloader.call(url)
    path  = Unarchiver.call(path, "*.xlsx")
    hash  = Hash.new { |h, k| h[k] = Set.new }
    queue = []

    XLSXParser.call(path, "Composition_communale", offset: 5) do |row|
      hash[row["EPCI"]] << row["DEP"] if row["EPCI"].present? && row["DEP"].present?
    end

    hash.each do |siren, codes|
      next if codes.size > 1

      # A generic name is provided to bypass not-null constraint.
      queue << {
        siren:            siren,
        name:             "-",
        code_departement: codes.first
      }
    end

    EPCI.upsert_all(
      queue,
      unique_by:   %i[siren],
      update_only: %i[code_departement]
    )

    raise "Wrong EPCIs inserted" if EPCI.exists?(name: "-")
  end
end
