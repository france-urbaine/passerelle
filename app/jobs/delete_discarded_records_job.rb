# frozen_string_literal: true

class DeleteDiscardedRecordsJob < ApplicationJob
  queue_as :default

  DELETION_DELAYS = {
    "Collectivity" => 30.days,
    "DDFIP"        => 30.days,
    "Publisher"    => 30.days,
    "Office"       => 30.days,
    "Package"      => 30.days,
    "Report"       => 30.days,
    "User"         => 1.day
  }.freeze

  def perform
    DELETION_DELAYS.each do |model_name, duration|
      model_name.constantize.discarded_over(duration).destroy_all
    end
  end
end
