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

    transmission.packages.preload(:reports, ddfip: { users: :user_form_types }).find_each do |package|
      types = package.reports.map(&:form_type).uniq

      package.ddfip.users.each do |user|
        next unless user.notifiable?
        next unless user.organization_admin? || user.user_form_types.any? { |uft| uft.form_type.in?(types) }

        Transmissions::Mailer.complete(user, package).deliver_later
      end
    end
  end
end
