# frozen_string_literal: true

require_relative "../base"

module CLI
  class Setup
    class User < Base
      def call
        say "Setup user"

        email, first_name, last_name = request_user_data_from_git
        email ||= request_user_email

        say "Verify user existence"
        say "Loading environment"
        require_relative "../../../config/environment"

        user = ::User.find_by(email: email)

        if user&.confirmed?
          say ""
          say "✓ This user already exists and is ready to log in!"
          return
        end

        if user
          say ""
          say "✓ This user already exists but is not yet confirmed."
        else
          first_name ||= request_user_first_name
          last_name  ||= request_user_last_name

          user = create_user(
            email:      email,
            first_name: first_name,
            last_name:  last_name
          )

          say ""
          say "✓ Your user has been created."
        end

        url = Rails.application.routes.url_helpers.user_registration_url(
          host:  "http://localhost:3000",
          token: user.confirmation_token
        )

        say <<~MESSAGE
            To complete your registration process:

            1. Start a server with the command:

                bin/dev

            2. Then, follow the link below:

                #{url}
          \x5
        MESSAGE
      end

      def request_user_data_from_git
        email = `git config --get user.email`.strip
        name  = `git config --get user.name`.strip.split(" ", 2)

        return if email.nil? || email.empty?

        first_name = name[0]
        last_name  = name[1]

        say "We found this user data in your git config:"
        say ""
        say "    email:         #{email}"
        say "    first_name:    #{first_name}" if first_name
        say "    last_name:     #{last_name}"  if last_name
        say ""
        say "Would you like to use this data to create a new user ? [Yn]"

        [email, first_name, last_name] if ask == "Y"
      end

      def request_user_email
        loop do
          say "Please enter your email:"
          email = ask
          return email unless email.empty?
        end
      end

      def request_user_first_name
        say "Please enter your first name (or press enter to generate a random value):"
        ask.presence || Faker::Name.first_name
      end

      def request_user_last_name
        say "Please enter your last name (or press enter to generate a random value):"
        ask.presence || Faker::Name.last_name
      end

      def create_user(**attributes)
        publisher.users.create!(
          **attributes,
          organization_admin: true,
          super_admin:        true,
          password:           Devise.friendly_token,
          &:skip_confirmation_notification!
        )
      end

      def publisher
        Publisher.create_or_find_by(
          siren: "511022394",
          name: "Solutions & Territoire",
          &:skip_uniqueness_validation!
        )
      end
    end
  end
end
