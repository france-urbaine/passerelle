# frozen_string_literal: true

# This job use files provided by INSEE :
#   https://www.insee.fr/fr/information/2510634
#
# You can launch the job using :
#   ImportEpcisJob.perform_now("https://www.insee.fr/fr/statistiques/fichier/2510634/Intercommunalite_Metropole_au_01-01-2022.zip")
#
# This job is called when seeding Data :
#   rails db:seed
#
class ImportEpcisJob < ApplicationJob
  queue_as :default

  def perform(url)
    path = Downloader.call(url)
    path = Unarchiver.call(path, "*.xlsx")

    XLSXParser.call(path, "EPCI", offset: 5) do |row|
      enqueue_row(row)
    end

    flush

    ImportEpcisDepartementsJob.perform_later(url)
  end

  def enqueue_row(row)
    return if row["EPCI"].blank?
    return if row["LIBEPCI"].blank?
    return unless row["EPCI"].match?(EPCI::SIREN_REGEXP)

    queue << {
      siren:  row["EPCI"],
      name:   row["LIBEPCI"],
      nature: row["NATURE_EPCI"]
    }

    flush if queue.size >= 100
  end

  def queue
    @queue ||= []
  end

  def flush
    EPCI.upsert_all(queue, unique_by: %i[siren]) if queue.any?
    queue.clear
  end
end
