# frozen_string_literal: true

namespace :cron do
  desc "Daily tasks"
  task daily: :environment do
    DeleteDiscardedRecordsJob.perform_later
  end
end
