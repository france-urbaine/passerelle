# frozen_string_literal: true

module Account
  class Mailer < Devise::Mailer
    def confirmation_instructions(record, token, opts = {})
      opts[:subject]

      super(record, token, opts)
    end
  end
end
