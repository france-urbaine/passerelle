# frozen_string_literal: true

# This job use files provided by INSEE :
#   https://www.insee.fr/fr/information/2028028
#
# You can launch the job using :
#   ImportCommunesJob.perform_now("https://www.insee.fr/fr/statistiques/fichier/2028028/table-appartenance-geo-communes-21.zip")
#
# This job is called when seeding Data :
#   rails db:seed
#
class ImportCommunesJob < ApplicationJob
  queue_as :default

  def perform(url)
    path = Downloader.call(url)
    path = Unarchiver.call(path, "*.xlsx")

    XLSXParser.call(path, "COM", offset: 5) do |row|
      enqueue(row)
    end

    XLSXParser.call(path, "ARM", offset: 5) do |row|
      enqueue(row)
    end

    flush
  end

  def enqueue(row)
    return if row["CODGEO"].blank?
    return if row["LIBGEO"].blank?
    return unless row["CODGEO"].match?(Commune::CODE_INSEE_REGEXP)
    return unless row["DEP"].match?(Commune::CODE_DEPARTEMENT_REGEXP)

    row["EPCI"] = nil unless row["EPCI"].match?(Commune::SIREN_REGEXP)

    queue << {
      code_insee:       row["CODGEO"],
      name:             row["LIBGEO"],
      code_departement: row["DEP"],
      siren_epci:       row["EPCI"]
    }

    flush if queue.size >= 100
  end

  def queue
    @queue ||= []
  end

  def flush
    Commune.upsert_all(queue, unique_by: %i[code_insee]) if queue.any?
    queue.clear
  end
end
