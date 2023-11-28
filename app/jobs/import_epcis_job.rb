# frozen_string_literal: true

# This job use files provided by INSEE :
#   https://www.insee.fr/fr/information/2510634
#
# You can launch the job using :
#   ImportEPCIsJob.perform_now(Passerelle::Application::DEFAULT_EPCIS_URL)
#
# This job is called when seeding Data :
#   rails db:seed
#
class ImportEPCIsJob < ApplicationJob
  queue_as :default

  def perform(url)
    path = Downloader.call(url)
    path = Unarchiver.call(path, "*.xlsx")

    XLSXParser.call(path, "EPCI", offset: 5) do |row|
      enqueue_row(row)
    end

    flush

    ImportEPCIsDepartementsJob.perform_later(url)
  end

  def enqueue_row(row)
    return if row["EPCI"].blank?
    return if row["LIBEPCI"].blank?
    return unless row["EPCI"].match?(EPCI::SIREN_REGEXP)

    nature = row["NATURE_EPCI"]
    nature = "ME" if nature == "METLYON"

    queue << {
      siren:  row["EPCI"],
      name:   row["LIBEPCI"],
      nature: nature
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
