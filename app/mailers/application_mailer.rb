# frozen_string_literal: true

# This file is excluded from coverage reports.
# We'll have to remove the :nocov: tag when we'll start using ApplicationMailer
#
# :nocov:
class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout "mailer"
end
# :nocov:
