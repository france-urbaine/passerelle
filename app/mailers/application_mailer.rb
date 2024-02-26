# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "ne-pas-repondre@passerelle-fiscale.fr"
  layout "mailer"
end
