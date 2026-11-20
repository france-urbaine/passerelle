# frozen_string_literal: true

namespace :sidekiq do
  desc "Flushes Sidekiq Redis database"
  task flushdb: :environment do
    Sidekiq.redis(&:flushdb)
  end
end
