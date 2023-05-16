# frozen_string_literal: true

module Users
  class Mailer < Devise::Mailer
    def confirmation_instructions(record, token, opts = {})
      if record.confirmed? && record.pending_reconfirmation?
        opts[:subject] = translate("devise.mailer.reconfirmation_instructions.subject")
      else
        opts[:subject] = translate("devise.mailer.confirmation_instructions.subject")
      end

      super(record, token, opts)
    end
  end
end
