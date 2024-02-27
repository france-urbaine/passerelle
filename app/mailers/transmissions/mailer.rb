# frozen_string_literal: true

module Transmissions
  class Mailer < ApplicationMailer
    def complete(user, package)
      @user    = user
      @package = package

      mail to: @user.email, subject: translate(".subject")
    end
  end
end
