# frozen_string_literal: true

require_relative "../base"

module CLI
  module Setup
    class User < Base
      def call(*)
        parse_options!(*, arguments_expected: false)

        email, first_name, last_name = request_user_data_from_git
        email ||= request_user_email

        user = find_user(email)

        if user
          say ""
          say "This user already exists."
          say "Would you like to update its password ? [Yn]"

          if ask == "Y"
            password = request_user_password
            user.update(password: password)
          end
        end

        if user&.confirmed?
          say ""
          say "✓ This user already exists and is ready to log in!"
          say ""
          return
        elsif user
          say ""
          say "✓ This user already exists but is not yet confirmed."
        else
          password     = request_user_password
          first_name ||= request_user_first_name
          last_name  ||= request_user_last_name

          user = create_user(
            email:      email,
            password:   password,
            first_name: first_name,
            last_name:  last_name
          )

          say ""
          say "✓ Your user has been created."
        end

        url = Rails.application.routes.url_helpers.user_registration_url(
          protocol: "http",
          host:     "localhost",
          port:     server_port,
          token:    user.confirmation_token
        )

        say <<~MESSAGE
            To complete the registration process:

              1. Start a server with the command:

                  #{bin_prefix('dev')}

              2. Then, follow the link below:

                  #{url}
          \x5
        MESSAGE
      end

      # Inside Docker, the server is published on the host port set by PORT
      # in docker-compose (see HOST_PORT in docker-compose.dev.yml).
      # Outside Docker, it's started on PORT (3000 by default, see bin/dev).
      #
      def server_port
        ENV.fetch("HOST_PORT") { ENV.fetch("PORT", 3000) }
      end

      def help
        say <<~HEREDOC
          Usage:

              #{bin_prefix('setup')} user

          Create a new user (or update its password) through an interactive command.
          \x5
        HEREDOC
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

      def request_user_password
        say "Please enter your new password : (or press enter to generate a random value)"
        ask(secret: true).presence || Devise.friendly_token
      end

      def request_user_first_name
        say "Please enter your first name : (or press enter to generate a random value)"
        ask.presence || Faker::Name.first_name
      end

      def request_user_last_name
        say "Please enter your last name : (or press enter to generate a random value)"
        ask.presence || Faker::Name.last_name
      end

      def find_user(email)
        say "Verify user existence"
        say "Loading environment"
        require_relative "../../../config/environment"

        ::User.find_by(email: email)
      end

      def create_user(**attributes)
        publisher.users.create!(
          **attributes,
          organization_admin: true,
          super_admin:        true,
          password:           Devise.friendly_token,
          **attributes,
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
