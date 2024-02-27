# frozen_string_literal: true

# You can launch the job using :
#   NotifyTransmissionCompletedJob.perform_now(Transmission.completed.first.id)
#
class NotifyTransmissionCompletedJob < ApplicationJob
  queue_as :default

  def perform(transmission_or_id)
    transmission = if transmission_or_id.is_a? Transmission
                     transmission_or_id
                   else
                     Transmission.find(transmission_or_id)
                   end

    transmission.packages.preload(ddfip: :users).find_each do |package|
      package.ddfip.users.select { |u| u.notifiable? && u.organization_admin? }.each do |user|
        Transmissions::Mailer.complete(user, package).deliver_now
      end
    end
  end
end
