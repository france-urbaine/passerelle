# frozen_string_literal: true

# This file is excluded from coverage reports.
# We'll have to remove the :nocov: tag when we'll start using ApplicationMailer
#
# :nocov:
class ApplicationMailer < ActionMailer::Base
  default from: "ne-pas-repondre@passerelle-fiscale.fr"
  layout "mailer"
end
# :nocov:
